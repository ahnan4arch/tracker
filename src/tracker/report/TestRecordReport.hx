package tracker.report;

import tracker.Main;

class TestRecordReport extends haxe.unit.TestCase
{
  public function testYearEmpty()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      assertEquals("2012 (0)\n", report.toString());
  }

  public function testYearOne()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("2012 (1)\n", report.toString());
  }

  public function testYearOneFixedStartStop()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("2012 (1)\n", report.toString());
  }

  public function testYearTwo()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2012 (3)\n", report.toString());
  }

  public function testYearTwoYears()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2011-11-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2012 (2)\n", report.toString());
  }

  public function testYearTwoYearsIncrement()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 1);
      report.include(Date.fromString("2012-01-08"), 1);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2012 (3)\n", report.toString());
  }

  public function testYearFirstYearBigger()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2011 (2)\n", report.toString());
  }

  public function testYearLowestYear()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_LOWEST, TOTAL);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2012 (1)\n", report.toString());
  }

  public function testYearLowestFirst()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_LOWEST, TOTAL);
      report.include(Date.fromString("2011-11-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2011 (1)\n", report.toString());
  }

    /*
      this test uses Date.now()
  public function testYearCurrent()
  {
      var report = new RecordReport(BIN_YEAR, KEEP_CURRENT, TOTAL);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("2012 (1)\n", report.toString());
  }
    */

    // month tests

  public function testMonthEmpty()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      assertEquals("2012-02 (0)\n", report.toString());
  }

  public function testMonthOne()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("2012-01 (1)\n", report.toString());
  }

  public function testMonthOneFixedStartStop()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), Main.NO_DATA);
      assertEquals("2012-01 (1)\n", report.toString());
  }

  public function testMonthTwo()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-02"), Main.NO_DATA);
      assertEquals("2012-01 (3)\n", report.toString());
  }

  public function testMonthTwoMonths()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-02-02"), 2);
      report.include(Date.fromString("2012-02-05"), Main.NO_DATA);
      assertEquals("2012-02 (2)\n", report.toString());
  }

  public function testMonthTwoYears()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2011-12-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2012-01 (2)\n", report.toString());
  }

  public function testMonthTwoMonthsIncrement()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2012-01-01"), 2);
      report.include(Date.fromString("2012-02-02"), 1);
      report.include(Date.fromString("2012-02-05"), 1);
      report.include(Date.fromString("2012-02-08"), 1);
      report.include(Date.fromString("2012-02-05"), Main.NO_DATA);
      assertEquals("2012-02 (3)\n", report.toString());
  }

  public function testMonthFirstMonthBigger()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_HIGHEST, TOTAL);
      report.include(Date.fromString("2011-12-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2011-12 (2)\n", report.toString());
  }

  public function testMonthLowestMonth()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_LOWEST, TOTAL);
      report.include(Date.fromString("2011-12-01"), 2);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2012-01 (1)\n", report.toString());
  }

  public function testMonthLowestFirst()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_LOWEST, TOTAL);
      report.include(Date.fromString("2011-12-01"), 1);
      report.include(Date.fromString("2012-01-02"), 2);
      report.include(Date.fromString("2012-01-05"), Main.NO_DATA);
      assertEquals("2011-12 (1)\n", report.toString());
  }

    /*
    //      this test uses Date.now()
  public function testMonthCurrent()
  {
      var report = new RecordReport(BIN_MONTH, KEEP_CURRENT, TOTAL);
      report.include(Date.fromString("2011-11-01"), 2);
      report.include(Date.fromString("2012-02-02"), 1);
      report.include(Date.fromString("2012-02-05"), Main.NO_DATA);
      assertEquals("2012-02 (1)\n", report.toString());
  }
*/
}
