import os
import json
from datetime import datetime
import google.generativeai as genai

# Gemini API Configuration
API_KEY = os.environ.get("GEMINI_API_KEY")
if API_KEY:
    genai.configure(api_key=API_KEY)
else:
    print("⚠️ Warning: GEMINI_API_KEY environment variable not found.")

def generate_extended_newsletter(topic, target_audience="General", tone="Professional"):
    """Gemini AI bebohar kore ekti premium ebong extended newsletter toiri kore."""
    print(f"⏳ '{topic}' er upor premium content toiri hocche...")
    
    try:
        model = genai.GenerativeModel('gemini-1.5-pro')
    except Exception:
        model = genai.GenerativeModel('gemini-pro')
        
    prompt = f"""
    Write a premium, comprehensive newsletter about: {topic}.
    Target Audience: {target_audience}
    Tone: {tone}
    
    Structure the newsletter with:
    1. A catchy subject line and preheader text.
    2. An engaging introduction that hooks the reader.
    3. 3 deep-dive sections with actionable insights, strategies, or bullet points.
    4. A 'Resource of the Week' or 'Pro Tip' section.
    5. A strong call-to-action (CTA) and concluding thought.
    6. Provide 3 suggested image keywords/prompts for Unsplash that match the sections.
    
    Please format the output in clean, structured Markdown.
    """
    
    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return f"❌ Error generating content: {e}"

def save_newsletter_files(topic, content):
    """Generated content ke Markdown ebong HTML duiti format-ee save kore."""
    if "❌ Error" in content:
        print(content)
        return

    date_str = datetime.now().strftime("%Y-%m-%d")
    clean_topic = topic.replace(' ', '_').lower()
    
    # 1. Save as Markdown File
    md_filename = f"newsletter_{clean_topic}_{date_str}.md"
    with open(md_filename, "w", encoding="utf-8") as file:
        file.write(content)
    print(f"✅ Premium Markdown file save hoyeche: {md_filename}")
    
    # 2. Save as ready-to-use HTML Email Template
    html_filename = f"newsletter_{clean_topic}_{date_str}.html"
    
    # Basic Markdown to simple HTML line break conversion for standard email templates
    html_body = content.replace('\n', '<br>')
    
    html_content = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333333; max-width: 600px; margin: 0 auto; padding: 20px; }}
        h1, h2, h3 {{ color: #1a365d; }}
        .container {{ border: 1px solid #e2e8f0; padding: 20px; border-radius: 8px; background-color: #ffffff; }}
    </style>
</head>
<body>
    <div class="container">
        {html_body}
    </div>
</body>
</html>"""
    
    with open(html_filename, "w", encoding="utf-8") as file:
        file.write(html_content)
    print(f"✅ HTML Email template save hoyeche: {html_filename}")

if __name__ == "__main__":
    print("🚀 Welcome to Premium AI Newsletter Generator (Extended Version) 🚀")
    
    user_topic = input("Kon bisoyer upor newsletter toiri korben? (e.g., Passive Income, Tech Trends): ")
    user_audience = input("Target audience ke? (e.g., Beginners, Creators) [Default: General]: ") or "General"
    user_tone = input("Tone kemon hobe? (e.g., Professional, Casual, Inspiring) [Default: Professional]: ") or "Professional"
    
    if user_topic.strip():
        generated_content = generate_extended_newsletter(user_topic, user_audience, user_tone)
        save_newsletter_files(user_topic, generated_content)
        print("\n🎉 Apnar digital product code-ti shofolvabe ready hoyeche!")
    else:
        print("⚠️ Apnake oboshoyi ekti topic moderation er jonne dite hobe!")
