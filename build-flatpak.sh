#!/bin/bash
set -e

echo "Building Yafti GTK Flatpak..."

# Install flatpak-builder if not present
if ! command -v flatpak-builder &> /dev/null; then
    echo "Installing flatpak-builder..."
    
    # Detect package manager and install
    if command -v dnf &> /dev/null; then
        sudo dnf install -y flatpak-builder
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm flatpak-builder
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y flatpak-builder
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y flatpak-builder
    else
        echo "Error: No supported package manager found (dnf, pacman, apt-get, zypper)"
        exit 1
    fi
fi

# Add Flathub repo if not present
if ! flatpak remote-list --user | grep -q flathub; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install runtime and SDK
echo "Installing GNOME runtime and SDK..."
flatpak install -y --user flathub org.gnome.Platform//48 org.gnome.Sdk//48 2>/dev/null || true

# Build the flatpak
echo "Building flatpak package..."
flatpak-builder --user --install --force-clean build-dir com.github.yafti.gtk.yml

# Export the flatpak bundle
echo "Exporting flatpak bundle..."
mkdir -p output
flatpak build-bundle ~/.local/share/flatpak/repo output/yafti-gtk.flatpak com.github.yafti.gtk

echo ""
echo "✓ Build complete!"
echo "✓ Flatpak bundle exported: yafti-gtk.flatpak"
echo ""
echo "To test the app:"
echo "  flatpak run com.github.yafti.gtk"
echo ""
echo "To install the bundle on another system:"
echo "  flatpak install yafti-gtk.flatpak"
