from pathlib import Path
import datetime

log_path = Path("docs/GENERATED_ASSET_LOG.md")
if not log_path.exists():
    log_path.write_text("# Generated Asset Log\n\n")

content = log_path.read_text()
timestamp = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S+0900")

entries = [
    f"{timestamp} | assets/runtime/ui/btn-primary-v1.png | btn_primary button graphic generated via PIL rounded rectangle",
    f"{timestamp} | assets/runtime/ui/btn-secondary-v1.png | btn_secondary button graphic generated via PIL rounded rectangle",
    f"{timestamp} | assets/runtime/ui/btn-danger-v1.png | btn_danger button graphic generated via PIL rounded rectangle",
    f"{timestamp} | assets/runtime/ui/btn-disabled-v1.png | btn_disabled button graphic generated via PIL rounded rectangle",
]

log_path.write_text(content + "\n".join(entries) + "\n")
