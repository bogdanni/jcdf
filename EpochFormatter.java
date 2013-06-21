package cdf;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Does string formatting of epoch values in various representations.
 * The methods of this object are not in general thread-safe.
 *
 * @author   Mark Taylor
 * @since    21 Jun 2013
 */
public class EpochFormatter {

    private final DateFormat epochFormat_ =
        createDateFormat( "yyyy-MM-dd' 'HH:mm:ss.SSS" );
    private static final TimeZone UTC = TimeZone.getTimeZone( "UTC" );
    private static final long AD0_UNIX_MILLIS = getAd0UnixMillis();
    private static final long J2000_UNIX_MILLIS = getJ2000UnixMillis();

    /**
     * Formats a CDF EPOCH value as an ISO-8601 date.
     *
     * @param  epoch  EPOCH value
     * @return   date string
     */
    public String formatEpoch( double epoch ) {
        long unixMillis = (long) ( epoch + AD0_UNIX_MILLIS );
        Date date = new Date( unixMillis );
        return epochFormat_.format( date );
    }

    /**
     * Formats a CDF EPOCH16 value as an ISO-8601 date.
     *
     * @param   epoch1  first element of EPOCH16 pair
     * @param   epoch2  second element of EPOCH16 pair
     * @return  date string
     */
    public String formatEpoch16( double epoch1, double epoch2 ) {
        return Double.toString( epoch1 ) + ", " + Double.toString( epoch2 );
    }

    /**
     * Formats a CDF TIME_TT2000 value as an ISO-8601 date.
     *
     * <strong>Note:</strong> this does not currently cope with leap
     * seconds, which it should do.
     *
     * @param  timeTt2k  TIME_TT2000 value
     * @return  date string
     */
    public String formatTimeTt2000( long timeTt2k ) {
        long j2kMillis = timeTt2k / 1000;
        int plusPicos = (int) ( timeTt2k % 1000 );
        if ( plusPicos < 0 ) {
            j2kMillis--;
            plusPicos += 1000;
        }
        long unixMillis = j2kMillis + J2000_UNIX_MILLIS;
        Date date = new Date( unixMillis );
        String txt = epochFormat_.format( date );
        StringBuffer pbuf = new StringBuffer( Integer.toString( plusPicos ) );
        while ( pbuf.length() < 3 ) {
            pbuf.insert( 0, '0' );
        }
        return txt + pbuf;
    }

    /**
     * Constructs a DateFormat object for a given pattern for UTC.
     *
     * @param  pattern  formatting pattern
     * @return  format
     * @see   java.text.SimpleDateFormat
     */
    private static DateFormat createDateFormat( String pattern ) {
        DateFormat fmt = new SimpleDateFormat( pattern );
        fmt.setTimeZone( UTC );
        fmt.setCalendar( new GregorianCalendar( UTC, Locale.UK ) );
        return fmt;
    }

    /**
     * Returns the CDF epoch (0000-01-01T00:00:00)
     * in milliseconds since the Unix epoch (1970-01-01T00:00:00).
     *
     * @return  -62,167,219,200,000
     */
    private static long getAd0UnixMillis() {
        GregorianCalendar cal = new GregorianCalendar( UTC, Locale.UK );
        cal.setLenient( true );
        cal.clear();
        cal.set( 0, 0, 1, 0, 0, 0 );
        long ad0 = cal.getTimeInMillis();

        // Fudge factor to make this calculation match the apparent result
        // from the CDF library.  Not quite sure why it's required, but
        // I think something to do with the fact that the first day is day 1
        // and signs around AD0/BC0.
        long fudge = 1000 * 60 * 60 * 24 * 2;  // 2 days
        return ad0 + fudge;
    }

    /**
     * Returns the J2000/TT_TIME2000 epoch (2000-01-01T12:00:00)
     * in milliseconds since the Unix epoch (1920-01-01T00:00:00).
     *
     * @return  +946,684,800,000
     */
    private static long getJ2000UnixMillis() {
        GregorianCalendar cal = new GregorianCalendar( UTC, Locale.UK );
        cal.clear();
        cal.set( 2000, 0, 1, 12, 0, 0 );
        long j2000 = cal.getTimeInMillis();
        return j2000;
    }
}
