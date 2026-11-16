// GENERATED SNAPSHOT of repository synthetic fixtures. Do not substitute real records.
// Sources: projects/commonwealth-os/historical/fixtures/{house,senate,municipal,issues}.json
// All jurisdictions and people are fictional; this is never official vote data.
window.COMMONWEALTH_SYNTHETIC = Object.freeze({
  "house": {
    "schema_version": 1,
    "synthetic": true,
    "source_system": "SYNTH_HOUSE",
    "source_id": "fixture://commonwealth/house/v1",
    "chamber": "HOUSE",
    "jurisdiction": "fictional-union",
    "people": [
      {
        "person_id": "fx-house-morgan",
        "name": "Morgan Alder (fictional)"
      },
      {
        "person_id": "fx-house-sam",
        "name": "Sam Briar (fictional)"
      },
      {
        "person_id": "fx-house-jordan",
        "name": "Jordan Cedar (fictional)"
      }
    ],
    "tenures": [
      {
        "tenure_id": "fx-h-tenure-old",
        "person_id": "fx-house-morgan",
        "seat": "H-07",
        "district": "07",
        "from": "2024-01-03",
        "to": "2025-01-03"
      },
      {
        "tenure_id": "fx-h-tenure-new",
        "person_id": "fx-house-sam",
        "seat": "H-07",
        "district": "07",
        "from": "2025-01-03",
        "to": "2027-01-03"
      },
      {
        "tenure_id": "fx-h-tenure-eight",
        "person_id": "fx-house-jordan",
        "seat": "H-08",
        "district": "08",
        "from": "2024-01-03",
        "to": "2027-01-03"
      }
    ],
    "questions": [
      {
        "question_id": "fx-house-roll-001",
        "date": "2024-06-10",
        "kind": "FINAL_PASSAGE",
        "rollcall_type": "RECORDED",
        "title": "Fictional House roll 001: riverfront public access",
        "proposition": "Adopt a fictional riverfront public-access improvement plan.",
        "result": "AGREED"
      },
      {
        "question_id": "fx-house-roll-002",
        "date": "2025-07-02",
        "kind": "FINAL_PASSAGE",
        "rollcall_type": "RECORDED",
        "title": "Fictional House roll 002: stormwater inspections",
        "proposition": "Update fictional stormwater inspection frequency.",
        "result": "NOT_AGREED"
      },
      {
        "question_id": "fx-house-roll-003",
        "date": "2025-09-03",
        "kind": "AMENDMENT",
        "rollcall_type": "RECORDED",
        "title": "Fictional House roll 003: parking amendment",
        "proposition": "Amend a fictional parking-space allocation formula.",
        "result": "AGREED"
      }
    ],
    "votes": [
      {
        "record_id": "fx-h-vote-001a",
        "question_id": "fx-house-roll-001",
        "person_id": "fx-house-morgan",
        "choice": "YEA"
      },
      {
        "record_id": "fx-h-vote-001b",
        "question_id": "fx-house-roll-001",
        "person_id": "fx-house-jordan",
        "choice": "NAY"
      },
      {
        "record_id": "fx-h-vote-002a",
        "question_id": "fx-house-roll-002",
        "person_id": "fx-house-sam",
        "choice": "NAY"
      },
      {
        "record_id": "fx-h-vote-002b",
        "question_id": "fx-house-roll-002",
        "person_id": "fx-house-jordan",
        "choice": "PRESENT"
      },
      {
        "record_id": "fx-h-vote-003a",
        "question_id": "fx-house-roll-003",
        "person_id": "fx-house-sam",
        "choice": "PRESENT"
      },
      {
        "record_id": "fx-h-vote-003b",
        "question_id": "fx-house-roll-003",
        "person_id": "fx-house-jordan",
        "choice": "NOT_VOTING"
      }
    ]
  },
  "senate": {
    "schema_version": 1,
    "synthetic": true,
    "source_system": "SYNTH_SENATE",
    "source_id": "fixture://commonwealth/senate/v1",
    "chamber": "SENATE",
    "jurisdiction": "fictional-union",
    "people": [
      {
        "person_id": "fx-senate-taylor",
        "name": "Taylor Elm (fictional)"
      },
      {
        "person_id": "fx-senate-robin",
        "name": "Robin Fir (fictional)"
      }
    ],
    "tenures": [
      {
        "tenure_id": "fx-s-tenure-one",
        "person_id": "fx-senate-taylor",
        "seat": "S-1",
        "district": "ALL",
        "from": "2023-01-03",
        "to": "2029-01-03"
      },
      {
        "tenure_id": "fx-s-tenure-two",
        "person_id": "fx-senate-robin",
        "seat": "S-2",
        "district": "ALL",
        "from": "2023-01-03",
        "to": "2027-01-03"
      }
    ],
    "questions": [
      {
        "question_id": "fx-senate-roll-001",
        "date": "2024-08-01",
        "kind": "CLOTURE",
        "rollcall_type": "RECORDED",
        "title": "Fictional Senate roll 001: debate limit on riverfront study",
        "proposition": "Limit further debate on a fictional riverfront access study.",
        "result": "AGREED"
      },
      {
        "question_id": "fx-senate-roll-002",
        "date": "2025-02-05",
        "kind": "FINAL_PASSAGE",
        "rollcall_type": "RECORDED",
        "title": "Fictional Senate roll 002: riverfront public access",
        "proposition": "Adopt a fictional riverfront public-access improvement plan.",
        "result": "AGREED"
      },
      {
        "question_id": "fx-senate-roll-003",
        "date": "2025-04-03",
        "kind": "NOMINATION",
        "rollcall_type": "RECORDED",
        "title": "Fictional Senate roll 003: synthetic planning commissioner nomination",
        "proposition": "Confirm the fictional commissioner of public facilities.",
        "result": "AGREED"
      }
    ],
    "votes": [
      {
        "record_id": "fx-s-vote-001a",
        "question_id": "fx-senate-roll-001",
        "person_id": "fx-senate-taylor",
        "choice": "YEA"
      },
      {
        "record_id": "fx-s-vote-001b",
        "question_id": "fx-senate-roll-001",
        "person_id": "fx-senate-robin",
        "choice": "NAY"
      },
      {
        "record_id": "fx-s-vote-002a",
        "question_id": "fx-senate-roll-002",
        "person_id": "fx-senate-taylor",
        "choice": "YEA"
      },
      {
        "record_id": "fx-s-vote-003a",
        "question_id": "fx-senate-roll-003",
        "person_id": "fx-senate-taylor",
        "choice": "YEA"
      },
      {
        "record_id": "fx-s-vote-003b",
        "question_id": "fx-senate-roll-003",
        "person_id": "fx-senate-robin",
        "choice": "NOT_VOTING"
      }
    ]
  },
  "municipal": {
    "schema_version": 1,
    "synthetic": true,
    "source_system": "SYNTH_MUNICIPAL",
    "source_id": "fixture://commonwealth/municipal/v1",
    "chamber": "MUNICIPAL",
    "jurisdiction": "fictional-river-city",
    "people": [
      {
        "person_id": "fx-city-avery",
        "name": "Avery Grove (fictional)"
      },
      {
        "person_id": "fx-city-casey",
        "name": "Casey Harbor (fictional)"
      },
      {
        "person_id": "fx-city-riley",
        "name": "Riley Juniper (fictional)"
      }
    ],
    "tenures": [
      {
        "tenure_id": "fx-m-tenure-old",
        "person_id": "fx-city-avery",
        "seat": "M-02",
        "district": "02",
        "from": "2023-01-01",
        "to": "2025-01-01"
      },
      {
        "tenure_id": "fx-m-tenure-new",
        "person_id": "fx-city-casey",
        "seat": "M-02",
        "district": "02",
        "from": "2025-01-01",
        "to": "2027-01-01"
      },
      {
        "tenure_id": "fx-m-tenure-three",
        "person_id": "fx-city-riley",
        "seat": "M-03",
        "district": "03",
        "from": "2023-01-01",
        "to": "2027-01-01"
      }
    ],
    "questions": [
      {
        "question_id": "fx-city-roll-001",
        "date": "2024-10-11",
        "kind": "MOTION",
        "rollcall_type": "RECORDED",
        "title": "Fictional River City roll 001: riverfront public access",
        "proposition": "Adopt a fictional riverfront public-access improvement plan.",
        "result": "AGREED"
      },
      {
        "question_id": "fx-city-voice-002",
        "date": "2025-04-01",
        "kind": "MOTION",
        "rollcall_type": "VOICE",
        "title": "Fictional River City voice vote: riverfront public access",
        "proposition": "Adopt a fictional riverfront public-access improvement plan.",
        "result": "AGREED"
      },
      {
        "question_id": "fx-city-roll-003",
        "date": "2025-07-15",
        "kind": "AMENDMENT",
        "rollcall_type": "RECORDED",
        "title": "Fictional River City roll 003: stormwater amendment",
        "proposition": "Amend the fictional stormwater inspection schedule with an exception.",
        "result": "NOT_AGREED"
      }
    ],
    "votes": [
      {
        "record_id": "fx-m-vote-001a",
        "question_id": "fx-city-roll-001",
        "person_id": "fx-city-avery",
        "choice": "YEA"
      },
      {
        "record_id": "fx-m-vote-001b",
        "question_id": "fx-city-roll-001",
        "person_id": "fx-city-riley",
        "choice": "NAY"
      },
      {
        "record_id": "fx-m-vote-003a",
        "question_id": "fx-city-roll-003",
        "person_id": "fx-city-casey",
        "choice": "NAY"
      }
    ]
  },
  "issues": {
    "schema_version": 1,
    "synthetic": true,
    "source_system": "SYNTH_ISSUES",
    "source_id": "fixture://commonwealth/issues/v1",
    "chamber": "ISSUES",
    "jurisdiction": "fictional-comparative-research",
    "issues": [
      {
        "issue_id": "fx-issue-riverfront",
        "title": "Fictional riverfront public access",
        "proposition": "Adopt a fictional riverfront public-access improvement plan."
      },
      {
        "issue_id": "fx-issue-stormwater",
        "title": "Fictional stormwater inspections",
        "proposition": "Update fictional stormwater inspection frequency."
      },
      {
        "issue_id": "fx-issue-transit",
        "title": "Fictional regional transit",
        "proposition": "Authorize a fictional transit route expansion."
      }
    ],
    "correspondence": [
      {
        "link_id": "fx-link-h1",
        "issue_id": "fx-issue-riverfront",
        "question_id": "fx-house-roll-001",
        "relation": "EXACT_QUESTION",
        "reviewer": "fictional-reviewer-a",
        "rationale": "Same canonical proposition; direct final-passage procedure (fixture only)."
      },
      {
        "link_id": "fx-link-s1",
        "issue_id": "fx-issue-riverfront",
        "question_id": "fx-senate-roll-001",
        "relation": "TOPIC_ONLY",
        "reviewer": "fictional-reviewer-b",
        "rationale": "Cloture concerns debate; its Yea does not establish substantive support."
      },
      {
        "link_id": "fx-link-s2",
        "issue_id": "fx-issue-riverfront",
        "question_id": "fx-senate-roll-002",
        "relation": "EXACT_QUESTION",
        "reviewer": "fictional-reviewer-b",
        "rationale": "Exact proposition and direct final passage, but synthetic."
      },
      {
        "link_id": "fx-link-m1",
        "issue_id": "fx-issue-riverfront",
        "question_id": "fx-city-roll-001",
        "relation": "EXACT_QUESTION",
        "reviewer": "fictional-reviewer-c",
        "rationale": "Exact proposition and direct motion."
      },
      {
        "link_id": "fx-link-m2",
        "issue_id": "fx-issue-riverfront",
        "question_id": "fx-city-voice-002",
        "relation": "EXACT_QUESTION",
        "reviewer": "fictional-reviewer-c",
        "rationale": "Same direct motion but no individually named voice-ballot data."
      },
      {
        "link_id": "fx-link-h2",
        "issue_id": "fx-issue-stormwater",
        "question_id": "fx-house-roll-002",
        "relation": "EXACT_QUESTION",
        "reviewer": "fictional-reviewer-a",
        "rationale": "Same canonical proposition and direct final passage."
      },
      {
        "link_id": "fx-link-m3",
        "issue_id": "fx-issue-stormwater",
        "question_id": "fx-city-roll-003",
        "relation": "SUBSTANTIVE_REVIEWED",
        "reviewer": "fictional-reviewer-c",
        "rationale": "Different amendment with an exception; not an equivalent final vote."
      },
      {
        "link_id": "fx-link-h3",
        "issue_id": "fx-issue-stormwater",
        "question_id": "fx-house-roll-003",
        "relation": "UNREVIEWED",
        "reviewer": "fictional-reviewer-a",
        "rationale": "Deliberately questionable cross-topic candidate; never treated as equivalence."
      }
    ]
  }
});
