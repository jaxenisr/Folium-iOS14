#!/usr/bin/env python3
"""Point the Xcode project at the local iOS 14-compatible SharedDependencies checkout."""

from pathlib import Path
import json
import re
import sys

root = Path.cwd()

package_swift = root / "SharedDependencies" / "Package.swift"
if not package_swift.exists():
    sys.exit("SharedDependencies/Package.swift is missing")

manifest = package_swift.read_text()
manifest = manifest.replace(".iOS(.v16)", ".iOS(.v14)")
package_swift.write_text(manifest)
assert ".iOS(.v14)" in manifest

project = root / "Folium.xcodeproj" / "project.pbxproj"
contents = project.read_text()

pattern = re.compile(
    r'(?P<id>[0-9A-F]{24}) /\* XCRemoteSwiftPackageReference "SharedDependencies" \*/ = \{\n'
    r'\s*isa = XCRemoteSwiftPackageReference;\n'
    r'\s*repositoryURL = "https://github\.com/folium-app/SharedDependencies";\n'
    r'\s*requirement = \{[^}]*\};\n'
    r'\s*\};',
    re.S,
)


def local_reference(match: re.Match) -> str:
    return (
        f'{match.group("id")} /* XCLocalSwiftPackageReference "SharedDependencies" */ = {{\n'
        "\t\t\tisa = XCLocalSwiftPackageReference;\n"
        "\t\t\trelativePath = SharedDependencies;\n"
        "\t\t};"
    )


contents, replacements = pattern.subn(local_reference, contents)
if replacements == 0:
    if 'XCLocalSwiftPackageReference' not in contents or 'relativePath = SharedDependencies;' not in contents:
        sys.exit("SharedDependencies is neither a remote nor a local package reference")
    print("SharedDependencies is already local")
elif replacements == 1:
    project.write_text(contents)
    print("Replaced the remote SharedDependencies package with the local checkout")
else:
    sys.exit(f"expected one SharedDependencies package reference, found {replacements}")

resolved = root / "Folium.xcodeproj" / "project.xcworkspace" / "xcshareddata" / "swiftpm" / "Package.resolved"
if resolved.exists():
    data = json.loads(resolved.read_text())
    pins = data.get("pins", [])
    kept = [pin for pin in pins if "SharedDependencies" not in pin.get("location", "")]
    if len(kept) != len(pins):
        data["pins"] = kept
        resolved.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")

print("Configured SharedDependencies at iOS 14 for this build")
