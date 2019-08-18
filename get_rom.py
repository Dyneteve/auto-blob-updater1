from requests import get
from datetime import datetime as dt
import json
with open('laurus_stable.json', 'wb') as load:
    load.write(get("https://raw.githubusercontent.com/XiaomiFirmwareUpdater/xiaomifirmwareupdater.github.io/master/data/devices/latest/laurus.json").content)
fw_stable = json.loads(open('laurus_stable.json').read())
stable_date = dt.strptime(fw_stable[0]["date"], "%Y-%m-%d")
if stable_date:
    URL="https://bigota.d.miui.com/"
    version=fw_stable[0]["versions"]["miui"]
    with open('/tmp/version','wb') as load:
        load.write(str.encode(version))
    URL+=version
    URL+="/"
    file=fw_stable[0]["filename"]
    file=file[10:]
    URL+=file
    print("Fetching Stable ROM......")
with open('rom.zip', 'wb') as load:
    load.write(get(URL).content)