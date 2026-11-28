import tempfile
import unittest
import zipfile
from pathlib import Path
from overlay import build


class OverlayTest(unittest.TestCase):
    def test_fixture_and_rejections(self):
        protocol = Path(__file__).with_name('repair_protocol.md')
        with tempfile.TemporaryDirectory() as t:
            p = Path(t)
            s = p/'sample'; s.mkdir()
            (s/'agent.yaml').write_text('fixture: true\n')
            (s/'prompts').mkdir()
            (s/'prompts/root.md').write_text('fixture {problem_description}\n')
            (s/'configs').mkdir()
            (s/'configs/sampling.yaml').write_text('temperature: 0.2\n')
            a = build(s,'prompts/root.md',protocol,p/'a.zip')
            b = build(s,'prompts/root.md',protocol,p/'b.zip')
            self.assertEqual(a.read_bytes(), b.read_bytes())
            with zipfile.ZipFile(a) as z:
                self.assertEqual(z.read('agent.yaml'), (s/'agent.yaml').read_bytes())
                self.assertEqual(z.read('configs/sampling.yaml'), (s/'configs/sampling.yaml').read_bytes())
                self.assertIn(protocol.read_bytes(), z.read('prompts/root.md'))
                self.assertIn(b'{problem_description}', z.read('prompts/root.md'))
            for prompt in ('../outside.md','prompts/missing.md','agent.yaml'):
                with self.assertRaises(ValueError):
                    build(s,prompt,protocol,p/'c.zip')
            (s/'bad.py').write_text('pass')
            with self.assertRaises(ValueError):
                build(s,'prompts/root.md',protocol,p/'c.zip')
            (s/'bad.py').unlink()
            (s/'link.md').symlink_to(protocol)
            with self.assertRaises(ValueError):
                build(s,'prompts/root.md',protocol,p/'c.zip')


if __name__ == '__main__':
    unittest.main()
