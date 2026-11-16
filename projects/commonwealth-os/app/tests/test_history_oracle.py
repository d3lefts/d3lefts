"""Independent brute-force join oracle (does not use the query reducer's helper functions)."""
from datetime import date
from itertools import product
from app.history import CATALOGUE, report

FIXED_TODAY=date(2026,11,15)


def brute_positions(d, start, end, group, scope):
    p=d['profiles'][0]
    active=lambda rec,day,a,b: date.fromisoformat(rec[a])<=day and (rec[b] is None or day<date.fromisoformat(rec[b]))
    active_today=FIXED_TODAY
    current_seats={a['seat'] for a in p['assignments'] if active(a,active_today,'from','until') and a['group']==group}
    results=set()
    for vote in d['rollcalls']:
        when=date.fromisoformat(vote['date'])
        if vote['group']!=group or not start<=when<=end:continue
        if scope=='PERSONAL_HISTORY':
            if not any(active(r,when,'from','until') for r in p['residences']):continue
            seats={a['seat'] for a in p['assignments'] if a['group']==group and active(a,when,'from','until')}
        else:seats=current_seats
        for term in d['terms']:
            if term['group']==group and term['seat'] in seats and active(term,when,'start','until'):
                choice=vote['positions'].get(term['official_id'],'NO_INDIVIDUAL_RECORD')
                results.add((vote['id'],term['official_id'],term['term_id'],choice))
    return results


def test_brute_force_two_modes_all_groups_multiple_date_windows():
    windows=[('1993-01-01','1995-12-31'),('1998-08-24','2005-01-01'),
             ('2007-01-03','2012-01-02'),('2012-01-03','2018-06-30'),
             ('2018-07-01','2022-01-02'),('2022-01-03','2026-11-15'),
             ('1990-01-01','2026-11-15')]
    for scope, group, (start,end) in product(['PERSONAL_HISTORY','CURRENT_SEATS'],
                    [g['id'] for g in CATALOGUE['groups']],windows):
        q=report(CATALOGUE,today=FIXED_TODAY,from_date=start,to_date=end,group=group,
                 mode=scope,page_size=100)
        observed={(r['rollcall_id'],r['official_id'],r['term_id'],r['member_position']) for r in q['rows']}
        expected=brute_positions(CATALOGUE,date.fromisoformat(start),date.fromisoformat(end),group,scope)
        assert observed==expected, (group,scope,start,end,observed.symmetric_difference(expected))
