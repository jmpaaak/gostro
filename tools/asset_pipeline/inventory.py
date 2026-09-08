import json
import re
import os

base_path = '/Users/jm/orca/workspaces/interactive-story-game-factory/gostro/'

inventory = []

# play-card
for kind in ['hongdan', 'cheongdan', 'chodan', 'godori', 'pi']:
    inventory.append({"id": f"play-card.{kind}", "category": "play-card", "name": kind})

# gwang
with open(base_path + 'game/data/gwang_jokers.json', 'r') as f:
    gwang_data = json.load(f)
    for g in gwang_data["jokers"]:
        inventory.append({"id": f"gwang.{g['id']}", "category": "gwang", "name": g.get('name', g['id'])})

# lua data files
def parse_lua_ids(filepath, prefix, category):
    with open(base_path + filepath, 'r') as f:
        content = f.read()
    # find lines like `id = "..."` or `{ id = "..."`
    matches = re.finditer(r'id\s*=\s*"([^"]+)"(?:.*?name\s*=\s*"([^"]+)")?', content)
    for m in matches:
        id_val = m.group(1)
        name_val = m.group(2) or id_val
        inventory.append({"id": f"{prefix}.{id_val}", "category": category, "name": name_val})

parse_lua_ids('game/planets.lua', 'planet', 'planet')
parse_lua_ids('game/tarots.lua', 'tarot', 'tarot')
parse_lua_ids('game/vouchers.lua', 'voucher', 'voucher')
parse_lua_ids('game/tags.lua', 'tag', 'tag')
parse_lua_ids('game/boss_blinds.lua', 'boss-blind', 'boss-blind')
parse_lua_ids('game/packs.lua', 'pack', 'pack')

# static / structural UI elements
ui_elements = [
    "ui.menu_bg", "ui.play_bg", "ui.shop_bg",
    "ui.panel_wood", "ui.panel_metal", "ui.panel_glass",
    "ui.btn_primary", "ui.btn_secondary", "ui.btn_danger", "ui.btn_disabled",
    "ui.icon_chip", "ui.icon_mult", "ui.icon_money",
    "ui.icon_deck", "ui.icon_discard", "ui.icon_hand",
    "ui.effect_select", "ui.effect_score", "ui.effect_lock",
    "ui.effect_win", "ui.effect_loss",
    "ui.deck_blue", "ui.deck_red", "ui.deck_yellow",
    "ui.stake_white", "ui.stake_red", "ui.stake_green",
    "ui.blind_small", "ui.blind_big",
    "effect.foil", "effect.hologram", "effect.polychrome"
]

for el in ui_elements:
    cat = el.split('.')[0]
    inventory.append({"id": el, "category": cat, "name": el})


manifest_path = base_path + 'assets/manifest.json'
with open(manifest_path, 'r') as f:
    manifest = json.load(f)

existing_assets = {a['id']: a for a in manifest['assets']}

for item in inventory:
    if item['id'] not in existing_assets:
        new_asset = {
            "id": item['id'],
            "category": item['category'],
            "status": "pending",
            "name": item['name']
        }
        manifest['assets'].append(new_asset)

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f"Added {len(manifest['assets']) - len(existing_assets)} missing items to manifest.json.")

