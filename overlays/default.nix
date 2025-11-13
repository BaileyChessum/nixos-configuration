# This just returns an array of the other overlays, 
# This makes easy to comment out overlays I want to disable.
[
  (import ./wayland)
  (import ./ides)
  (import ./overlays/wayland)
]