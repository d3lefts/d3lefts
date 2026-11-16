"""Executable local UX smoke test. Requires: pip install playwright; Chromium browser.
No network calls, no source integration, no real ballots or assurance certification.
"""
from pathlib import Path
from playwright.sync_api import sync_playwright

html = Path(__file__).with_name('index.html').read_text(encoding='utf-8')
with sync_playwright() as p:
    executable = '/usr/bin/chromium' if Path('/usr/bin/chromium').exists() else None
    browser = p.chromium.launch(headless=True, executable_path=executable, args=['--no-sandbox'])
    page = browser.new_page(viewport={'width': 1440, 'height': 900})
    page.set_default_timeout(2500)
    errors = []
    page.on('pageerror', lambda err: errors.append(str(err)))
    page.set_content(html, wait_until='domcontentloaded')
    assert 'One decision.' in page.locator('#content').inner_text()
    page.get_by_role('button', name='Begin guided scenario').click()
    assert page.get_by_role('heading', name='Campus Walkway Improvements').count() == 1
    page.get_by_role('tab', name='Compare revisions').click()
    assert 'Illustrative diff' in page.locator('#content').inner_text()
    page.get_by_role('button', name='Draft amendment').click()
    page.locator('#amendText').fill(
        'Install eight shade structures along the east campus walkway, '
        'with installation scheduled for the next academic year.'
    )
    page.get_by_role('button', name='Save simulated amendment').click()
    assert 'SYN-014@v4' in page.locator('#content').inner_text()
    page.get_by_role('button', name='Continue to demo vote').click()
    assert page.get_by_role('button', name='Review and confirm simulation').is_disabled()
    page.locator('input[type=radio][value=Support]').check()
    assert page.get_by_role('button', name='Review and confirm simulation').is_enabled()
    page.get_by_role('button', name='Review and confirm simulation').click()
    assert page.get_by_role('dialog').count() == 1
    page.get_by_role('button', name='Record demo response').click()
    assert 'Submission recorded (demo)' in page.locator('#content').inner_text()
    page.get_by_role('button', name='View Proof Passport').click()
    assert 'Not independently certified' in page.locator('#content').inner_text()
    page.locator('#scenario').select_option('stale')
    page.get_by_role('button', name='Run sample checks').click()
    assert 'EVIDENCE CHECK FAILED' in page.locator('#content').inner_text()
    page.locator('#scenario').select_option('missing')
    page.get_by_role('button', name='Run sample checks').click()
    assert 'Rule evidence missing' in page.locator('#content').inner_text()
    with page.expect_download() as download_info:
        page.get_by_role('button', name='Export synthetic evidence JSON').click()
    assert download_info.value.suggested_filename == 'SYN-014-demo-proof-passport.json'
    assert errors == [], errors

    mobile = browser.new_page(viewport={'width': 390, 'height': 844})
    mobile.set_content(html, wait_until='domcontentloaded')
    mobile.get_by_role('button', name='Begin guided scenario').click()
    assert mobile.evaluate('document.documentElement.scrollWidth <= document.documentElement.clientWidth')
    browser.close()
print('PASS: review, amendment version, nondefault vote, confirmation, local receipt, stale/missing checks, JSON download, mobile width')
