#!/bin/bash
set -e

echo "=== OpenArm v1.0 Bimanual URDF Viewer ==="

source /opt/ros/humble/setup.bash

URDF_DIR=/home/oem/gitfork/openarm_description

# --- Step 1: Use pre-flattened bimanual URDF ---
FLATTENED="$URDF_DIR/assets/robot/openarm_v1.0/urdf/openarm_v10_bimanual.urdf"
echo "[1/3] Using pre-flattened bimanual URDF:"
echo "  -> $(wc -l < "$FLATTENED") lines"

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
  arm_type:=v10 rviz_config:=bimanual.rviz use_flat_urdf:=true
