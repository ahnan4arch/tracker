package tracker.report;

import tracker.Main;

class TestCountReport extends haxe.unit.TestCase
{
  public function testEmpty()
  {
      var report = new CountReport();
      assertEquals("0 occurrences\n", report.toString());
  }

  public function testOne()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("1 occurrence\n", report.toString());
  }

  public function testOneFixedStartStop()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("1 occurrence\n", report.toString());
  }

  public function testTwo()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2 occurrences\n", report.toString());
  }


  public function testTwoGap()
  {
      var report = new CountReport();
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2 occurrences\n", report.toString());
  }
}
