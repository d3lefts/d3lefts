from pathlib import Path
from playwright.sync_api import sync_playwright
from PIL import Image, ImageOps, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
url=(ROOT/'living_voter_mobile_v1_3.html').as_uri()
shots=ROOT/'assets'
shots.mkdir(exist_ok=True)
with sync_playwright() as pw:
    browser=pw.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--disable-dev-shm-usage'])
    page=browser.new_page(viewport={'width':390,'height':844},device_scale_factor=1,is_mobile=True,has_touch=True)
    errors=[]
    page.on('pageerror',lambda e:errors.append(str(e)))
    page.set_content((ROOT/'living_voter_mobile_v1_3.html').read_text(encoding='utf-8'),wait_until='load')
    assert page.get_by_text('Government should be understandable.').is_visible()
    assert not page.get_by_role('navigation', name='Main navigation').is_visible()
    page.screenshot(path=str(shots/'01-welcome.png'),full_page=True)
    page.get_by_role('button',name='Start with a brief, optional survey').click()
    assert page.get_by_text('What matters to you?').is_visible()
    page.screenshot(path=str(shots/'02-survey.png'),full_page=True)
    for response in ['Support',"Don't support",'No preference','Need more information']:
        page.get_by_role('button',name=response,exact=True).click()
    assert page.get_by_role('heading',name='The Living Voter').is_visible()
    assert page.locator('.stat strong').first.inner_text().strip().startswith('4')
    page.screenshot(path=str(shots/'03-dashboard.png'),full_page=True)
    page.get_by_role('button', name='Review ›').click()
    assert page.get_by_text('Review my policy views').is_visible()
    assert page.get_by_text('Transparent administration').is_visible()
    page.get_by_role('button', name='Back to dashboard').click()
    assert page.get_by_role('heading',name='The Living Voter').is_visible()
    page.get_by_role('button', name='Explore', exact=True).click()
    assert page.get_by_text('Explore the record').is_visible()
    page.screenshot(path=str(shots/'04-explore.png'),full_page=True)
    page.get_by_role('button',name='Review the exact question').first.click()
    assert page.get_by_text('Understand your choices').is_visible()
    assert page.get_by_text('On Motion to Suspend the Rules and Pass, as Amended').is_visible()
    assert page.get_by_text('Sen. Katie Britt').count()==0, 'Representative votes should not be shown prematurely or in different chamber'
    page.screenshot(path=str(shots/'05-briefing.png'),full_page=True)
    page.get_by_role('button',name='I understand · simulate my vote').click()
    assert page.get_by_text('How would you have voted?').is_visible()
    page.screenshot(path=str(shots/'06-simulate.png'),full_page=True)
    page.get_by_role('button',name='Nay',exact=True).click()
    assert page.get_by_text('Now compare the decisions.').is_visible()
    assert page.get_by_text('Rep. Dale Strong').is_visible()
    assert page.get_by_text('Sen. Katie Britt').count()==0
    assert page.get_by_text('My retrospective vote').is_visible()
    assert 'Not Voting' not in page.locator('.persona').all_text_contents()
    page.screenshot(path=str(shots/'07-compare.png'),full_page=True)
    page.get_by_role('button',name='My votes').click()
    assert page.get_by_text('Your private vote history').is_visible()
    page.screenshot(path=str(shots/'08-history.png'),full_page=True)
    page.get_by_role('button',name='Delete my choice').click()
    assert page.get_by_text('Your ledger is empty.').is_visible()
    page.get_by_role('button',name='Explore',exact=True).click()
    page.get_by_role('button',name='Senate',exact=True).click()
    assert page.get_by_text('Cloture on Anna St. John nomination').is_visible()
    assert page.get_by_text('Local Communities & Bird Habitat Stewardship Act').count()==0
    page.get_by_role('button',name='Review the exact question').last.click()
    page.get_by_role('button',name='I understand · simulate my vote').click()
    page.get_by_role('button',name='No preference',exact=True).click()
    assert page.get_by_text('Sen. Tommy Tuberville').is_visible()
    assert page.get_by_text('Not Voting',exact=True).is_visible()
    assert page.get_by_text('Sen. Katie Britt').is_visible()
    page.get_by_role('button',name='Privacy',exact=True).click()
    page.screenshot(path=str(shots/'09-privacy.png'),full_page=True)
    page.get_by_role('button',name='Clear all private demo data').click()
    assert page.get_by_text('Government should be understandable.').is_visible()
    assert not errors, errors
    assert page.evaluate('document.documentElement.scrollWidth <= window.innerWidth'), 'horizontal overflow'
    # Check the other route bypassing survey entirely
    page.get_by_role('button',name='Skip survey · explore decisions').click()
    assert page.get_by_role('heading',name='The Living Voter').is_visible()
    print('PASS: mobile flow, opt-in survey, record lookup, delayed official comparison, procedural vote, choices, reset, skip, no JS errors')
    browser.close()

# Small visual overview: 3 columns, cropped top 780px of each mobile full-page screenshot.
labels=['01-welcome','02-survey','03-dashboard','04-explore','05-briefing','06-simulate','07-compare','08-history','09-privacy']
cellw,cellh=390,800
sheet=Image.new('RGB',(cellw*3, (cellh+44)*3),(14,20,32));draw=ImageDraw.Draw(sheet)
for k,label in enumerate(labels):
    im=Image.open(shots/(label+'.png')).convert('RGB')
    im=ImageOps.fit(im,(390,800),centering=(0.5,0))
    x=(k%3)*cellw; y=(k//3)*(cellh+44)
    sheet.paste(im,(x,y+30))
    draw.text((x+10,y+8),label.upper(),fill=(220,235,243))
sheet.save(shots/'mobile_storyboard_v1_3.png')
print('PASS: 9 screenshots and storyboard saved')
