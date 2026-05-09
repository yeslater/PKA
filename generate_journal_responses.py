#!/usr/bin/env python3
"""
Journal Response Generator — runs a local server that generates team responses to journal entries.
Personas: Camille (emotional processing), Anaïs (writing quality), Quinn (blind spots)
"""

import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
import google.generativeai as genai

# Get API key from environment
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    print("Error: GEMINI_API_KEY environment variable not set")
    print("Set it with: export GEMINI_API_KEY='your-key-here'")
    exit(1)

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-1.5-pro')

# Persona definitions
PERSONAS = {
    "Camille": {
        "title": "Life Coach & Psychologist",
        "prompt": """You are Camille, a Life Coach and Psychologist. Your role is to help Yvé understand his emotional patterns and what they reveal about him.

When responding to his journal entry:
1. Identify the emotional undercurrents and patterns you notice
2. Reflect back what you see happening beneath the surface
3. Connect it to the broader context of his life right now (separation from Chloé, parenting Matteo and Felix, personal reconstruction work with Rachel)
4. Offer one insight or reframe that might deepen his self-understanding

Keep it warm, direct, and focused on emotional clarity — not diagnosis. Write in 2-3 sentences."""
    },
    "Anaïs": {
        "title": "Writing Coach",
        "prompt": """You are Anaïs, a Writing Coach. Your role is to help Yvé strengthen his written expression and journaling quality.

When responding to his journal entry:
1. Notice the clarity and specificity of how he's expressing himself
2. Identify what's written well and what could be more precise
3. Suggest one concrete writing improvement: more specific details, clearer emotion words, tighter structure, or deeper description
4. Affirm the value of what he's already doing

Keep it practical and encouraging. Write in 2-3 sentences."""
    },
    "Quinn": {
        "title": "Creative Thinking Partner",
        "prompt": """You are Quinn, a Creative Thinking Partner. Your role is to help Yvé see blind spots and deeper questions he might be missing.

When responding to his journal entry:
1. Read for what's implied but not stated
2. Identify one assumption he might be making without realizing it
3. Pose one powerful question that could shift his perspective
4. Help him see a connection or pattern he might have missed

Keep it provocative but kind. Write in 2-3 sentences."""
    }
}

class ResponseHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/generate-responses':
            self.send_error(404)
            return

        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')
            data = json.loads(body)

            journal_entry = data.get('journalEntry', '').strip()
            date = data.get('date', '')

            if not journal_entry:
                self.send_error(400, "No journal entry provided")
                return

            # Generate responses from each persona
            responses = []
            for persona_name, persona_info in PERSONAS.items():
                try:
                    response = model.generate_content(
                        f"{persona_info['prompt']}\n\nHere is the journal entry:\n\n{journal_entry}",
                        generation_config=genai.types.GenerationConfig(
                            max_output_tokens=300,
                        )
                    )

                    response_text = response.text

                    responses.append({
                        "name": persona_name,
                        "title": persona_info["title"],
                        "content": response_text
                    })
                except Exception as e:
                    print(f"Error generating response from {persona_name}: {e}")
                    responses.append({
                        "name": persona_name,
                        "title": persona_info["title"],
                        "content": f"[Error generating response]"
                    })

            # Format response for storage
            response_data = {
                "date": date,
                "clusters": responses
            }

            # Send response
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode('utf-8'))

            print(f"Generated responses for {date}")

        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON")
        except Exception as e:
            print(f"Error: {e}")
            self.send_error(500, str(e))

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def log_message(self, format, *args):
        # Quieter logging
        pass


def main():
    port = 3847
    server_address = ('localhost', port)
    httpd = HTTPServer(server_address, ResponseHandler)

    print(f"✓ Journal Response Generator running on http://localhost:{port}")
    print("  Personas: Camille (emotional), Anaïs (writing), Quinn (blind spots)")
    print("  Press Ctrl+C to stop")
    print()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n✓ Server stopped")


if __name__ == '__main__':
    main()
