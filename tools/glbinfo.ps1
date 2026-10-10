# Prints the node tree, mesh names, animations and bounds of a .glb (reads its JSON chunk only).
param([string]$path, [switch]$tree)
$b = [IO.File]::ReadAllBytes($path)
$len = [BitConverter]::ToUInt32($b, 12)
$j = [Text.Encoding]::UTF8.GetString($b, 20, $len) | ConvertFrom-Json
"nodes $($j.nodes.Count)  meshes $($j.meshes.Count)  materials $($j.materials.Count)  skins $(@($j.skins).Count)  anims $(@($j.animations).Count)"
if ($j.animations) { foreach ($a in $j.animations) { "  anim '$($a.name)' channels $($a.channels.Count)" } }
$kids = @{}; for ($i = 0; $i -lt $j.nodes.Count; $i++) { foreach ($c in $j.nodes[$i].children) { $kids[[int]$c] = $i } }
function show($i, $d) {
  $n = $j.nodes[$i]; $m = if ($n.mesh -ne $null) { " [mesh $($j.meshes[$n.mesh].name)]" } else { '' }
  $t = if ($n.translation) { ' t=' + (($n.translation | ForEach-Object { [math]::Round($_, 2) }) -join ',') } else { '' }
  $s = if ($n.scale) { ' s=' + (($n.scale | ForEach-Object { [math]::Round($_, 3) }) -join ',') } else { '' }
  $r = if ($n.rotation) { ' r=' + (($n.rotation | ForEach-Object { [math]::Round($_, 2) }) -join ',') } else { '' }
  ('  ' * $d) + "$i $($n.name)$m$t$r$s"
  if ($d -lt 14) { foreach ($c in $n.children) { show $c ($d + 1) } }
}
if ($tree) { for ($i = 0; $i -lt $j.nodes.Count; $i++) { if (-not $kids.ContainsKey($i)) { show $i 0 } } }
foreach ($m in $j.meshes) { foreach ($p in $m.primitives) { $a = $j.accessors[$p.attributes.POSITION]; "  mesh '$($m.name)' min=$(($a.min | ForEach-Object { [math]::Round($_, 2) }) -join ',') max=$(($a.max | ForEach-Object { [math]::Round($_, 2) }) -join ',')" } }
