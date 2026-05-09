#!/Users/yves-erikslater/Desktop/PKA/.venv/bin/python3
"""
Claude book summary generator.
Usage: python3 claude_book_summary.py <pdf_path> <prompt_type> <output_file>
"""
import sys
import os
from pathlib import Path

try:
    from anthropic import Anthropic
except ImportError:
    print("Error: anthropic package not found. Install with: pip install anthropic")
    sys.exit(1)

def generate_summary(pdf_path: str, prompt_text: str, output_file: str) -> None:
    """Generate a book summary using Claude and the Anthropic Files API."""

    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("Error: ANTHROPIC_API_KEY environment variable not set", file=sys.stderr)
        sys.exit(1)

    client = Anthropic(api_key=api_key)

    # Read the PDF file
    pdf_path = Path(pdf_path)
    if not pdf_path.exists():
        print(f"Error: PDF file not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)

    # Upload the PDF using Files API
    print(f"Uploading PDF to Claude: {pdf_path}", file=sys.stderr)
    with open(pdf_path, "rb") as pdf_file:
        response = client.beta.files.upload(
            file=(pdf_path.name, pdf_file, "application/pdf"),
        )
        file_id = response.id

    print("Upload complete.", file=sys.stderr)

    # Create message with the uploaded file
    print("Generating summary...", file=sys.stderr)
    message = client.beta.messages.create(
        model="claude-opus-4-7",
        max_tokens=4000,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "document",
                        "source": {
                            "type": "file",
                            "file_id": file_id,
                        },
                    },
                    {
                        "type": "text",
                        "text": prompt_text,
                    }
                ],
            }
        ],
        betas=["files-api-2025-04-14"],
    )

    # Extract the summary text
    summary = message.content[0].text

    # Write to output file
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(summary)

    print(f"Summary written to: {output_file}", file=sys.stderr)

    # Clean up: delete the uploaded file
    try:
        client.beta.files.delete(file_id)
    except Exception as e:
        print(f"Warning: Could not delete uploaded file: {e}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 claude_book_summary.py <pdf_path> <prompt_type> <output_file>")
        sys.exit(1)

    pdf_path, prompt_type, output_file = sys.argv[1], sys.argv[2], sys.argv[3]
    generate_summary(pdf_path, prompt_type, output_file)
