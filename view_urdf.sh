#!/bin/bash
set -e

echo "=== OpenArm v1.0 Flattened URDF Viewer ==="

source /opt/ros/humble/setup.bash

URDF_DIR=/home/oem/gitroot/openarm_description

# --- Step 1: Flatten full bimanual URDF ---
echo "[1/3] Flattening URDF (resolving xacro, bimanual mode)..."
TMP_WORK=$(mktemp -d)
cp -r "$URDF_DIR" "$TMP_WORK/"
find "$TMP_WORK/openarm_description" -name '*.xacro' -o -name '*.yaml' | \
  while read f; do sed -i 's|\$(find openarm_description)|'"$TMP_WORK"'/openarm_description|g' "$f"; done

FLATTENED="$TMP_WORK/openarm_description/assets/robot/openarm_v1.0/urdf/openarm_v10.urdf"
xacro "$TMP_WORK/openarm_description/assets/robot/openarm_v1.0/urdf/openarm_v10.urdf.xacro" \
  > "$FLATTENED" 2>/dev/null

echo "  -> $(wc -l < "$FLATTENED") lines written"

# --- Step 2: Set up ament index ---
echo "[2/3] Registering package in ament index..."
TMP_PREFIX=$(mktemp -d)
mkdir -p "$TMP_PREFIX/share/ament_index/resource_index/packages"
touch "$TMP_PREFIX/share/ament_index/resource_index/packages/openarm_description"
ln -s "$URDF_DIR" "$TMP_PREFIX/share/openarm_description"
export AMENT_PREFIX_PATH="$TMP_PREFIX:$AMENT_PREFIX_PATH"

# --- Step 3: Launch display ---
echo "[3/3] Launching visualization via display_openarm.launch.py..."
ros2 launch "$URDF_DIR/launch/display_openarm.launch.py" \
  arm_type:=v10 rviz_config:=bimanual.rviz
