"""
Test value with a template specialization type.
"""
import lldb
from lldbsuite.test.decorators import *
from lldbsuite.test.lldbtest import *
from lldbsuite.test import lldbutil


class TemplateSpecializationTypeTestCase(TestBase):
    def test_template_specialization_cast_children(self):
        self.build()
        lldbutil.run_to_source_breakpoint(
            self, "// break here", lldb.SBFileSpec("main.cpp", False)
        )

        v = self.frame().EvaluateExpression("t")
        self.assertEqual(2, v.GetNumChildren())
        self.assertEqual("42", v.GetChildAtIndex(0).GetValue())
        self.assertEqual("21", v.GetChildAtIndex(1).GetValue())

        # Test a value of the TemplateSpecialization type. We turn
        # RecordType into TemplateSpecializationType by casting and
        # dereferencing a pointer to a record.
        v = self.frame().EvaluateExpression("*((TestObj<int>*)&t)")
        self.assertEqual(2, v.GetNumChildren())
        self.assertEqual("42", v.GetChildAtIndex(0).GetValue())
        self.assertEqual("21", v.GetChildAtIndex(1).GetValue())
