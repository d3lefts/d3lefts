from pathlib import Path
from playwright.sync_api import sync_playwright
p=Path(__file__).resolve().parents[1]
url=(p/'prepilot/living_voter_demo.html').as_uri()
with sync_playwright() as pw:
 b=pw.chromium.launch(headless=True, executable_path='/usr/bin/chromium',args=['--no-sandbox'])
 page=b.new_page(viewport={'width':390,'height':844},device_scale_factor=1)
 errors=[]
 page.on('pageerror',lambda e: errors.append(str(e)))
 page.set_content((p/'prepilot/living_voter_demo.html').read_text(),wait_until='load')
 assert page.get_by_text('Democracy, in the present tense.').is_visible()
 page.get_by_role('button',name='Start optional survey').click()
 for v in ['Support',"Don't support",'No preference','Need more information']:
  page.get_by_role('button',name=v,exact=True).click()
 assert page.get_by_text('Your living voter dashboard').is_visible()
 page.get_by_role('button',name='Review and simulate vote').first.click()
 assert page.get_by_text('What the chamber actually voted on').is_visible()
 page.get_by_role('button',name='Nay',exact=True).click()
 assert page.get_by_text('My decision history').is_visible()
 assert page.get_by_text('My retrospective choice:').is_visible()
 page.screenshot(path=str(p/'prepilot/mobile_dashboard_screenshot.png'),full_page=True)
 page.get_by_role('button',name='Clear my answers and restart').click()
 assert page.get_by_text('Democracy, in the present tense.').is_visible()
 assert not errors,errors
 print('PASS: mobile browser onboarding, survey, briefing, choice, comparison, reset and no page errors')
 b.close()
