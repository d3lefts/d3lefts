from pathlib import Path
import json
from jsonschema import Draft202012Validator, FormatChecker
p=Path(__file__).parent
schema=json.loads((p/'dap_passport.schema.json').read_text())
example=json.loads((p/'dap_passport_synthetic_example.json').read_text())
Draft202012Validator.check_schema(schema)
Draft202012Validator(schema, format_checker=FormatChecker()).validate(example)
print('Schema valid; synthetic example conforms (no assurance implied).')
