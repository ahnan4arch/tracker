package tracker.report;

class TestStreakReport extends haxe.unit.TestCase
{
  public function testOnEmpty()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      assertEquals("none", report.toString());
  }

  public function testOnOne()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("  1 day  starting on 2012-01-01", report.toString());
  }

  public function testOnOneWithFixedStart()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2011-12-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("  1 day  starting on 2012-01-01", report.toString());
  }

  public function testOnOneWithFixedEnd()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-05"), 0);
      assertEquals("  1 day  starting on 2012-01-01", report.toString());
  }

  public function testOnOneWithFixedEndWithOcc()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("  1 day  starting on 2012-01-01", report.toString());
  }

  public function testOnReplaceWithNewer()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-03", report.toString());
  }

  public function testOnTwoConsec()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      assertEquals("  2 days starting on 2012-01-01", report.toString());
  }

  public function testOnOneTwo()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-03", report.toString());
  }

  public function testOnTwoOne()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-01", report.toString());
  }

  public function testOnOccOnStartDay()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  1 day  starting on 2012-01-04", report.toString());
  }

  public function testOnOccOnEndDay()
  {
      var report = new StreakReport(KEEP_HIGHEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("  1 day  starting on 2012-01-04", report.toString());
  }

    // streak off

  public function testOffEmpty()
  {
      var report = new StreakReport(KEEP_LOWEST);
      assertEquals("none", report.toString());
  }

  public function testOffOne()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-02", report.toString());
  }

  public function testOffOneWithFixedStart()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-02", report.toString());
  }

  public function testOffOneWithFixedEnd()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("  1 day  starting on 2012-01-02", report.toString());
  }

  public function testOffOneWithFixedEndWithOcc()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-01"), 0);
      assertEquals("none", report.toString());
  }

  public function testOffReplaceWithNewer()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-05"), 1);
      assertEquals("  1 day  starting on 2012-01-04", report.toString());
  }

  public function testOffTwoConsec()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-02", report.toString());
  }

  public function testOffOneTwo()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-06"), 1);
      assertEquals("  2 days starting on 2012-01-04", report.toString());
  }

  public function testOffTwoOne()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-06"), 1);
      assertEquals("  2 days starting on 2012-01-02", report.toString());
  }

  public function testOffOccOnStartDay()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 0);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      assertEquals("  2 days starting on 2012-01-02", report.toString());
  }

  public function testOffOccOnEndDay()
  {
      var report = new StreakReport(KEEP_LOWEST);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-04"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("  2 days starting on 2012-01-02", report.toString());
  }


    // streak current

  public function testCurrentEmpty()
  {
      var report = new StreakReport(KEEP_CURRENT);
      assertEquals("none", report.toString());
  }

  public function testCurrentOneOn()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      assertEquals("  1 day  starting on 2012-01-01 (on)", report.toString());
  }

  public function testCurrentTwoOn()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 1);
      assertEquals("  2 days starting on 2012-01-01 (on)", report.toString());
  }

  public function testCurrentOneOff()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-02"), 0);
      assertEquals("  1 day  starting on 2012-01-02 (off)", report.toString());
  }

  public function testCurrentTwoOff()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("  2 days starting on 2012-01-02 (off)", report.toString());
  }

  public function testCurrentReplaceWithNewerOn()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      assertEquals("  1 day  starting on 2012-01-03 (on)", report.toString());
  }

  public function testCurrentReplaceWithNewerOff()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-04"), 0);
      assertEquals("  1 day  starting on 2012-01-04 (off)", report.toString());
  }

  public function testCurrentEndOnOffDay()
  {
      var report = new StreakReport(KEEP_CURRENT);
      report.include(Date.fromString("2012-01-01"), 1);
      report.include(Date.fromString("2012-01-03"), 1);
      report.include(Date.fromString("2012-01-03"), 0);
      assertEquals("  1 day  starting on 2012-01-03 (on)", report.toString());
  }
}