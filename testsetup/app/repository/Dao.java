package repository;

import play.Environment;
import play.Logger;
import util.ApplicationRootHelper;
import util.FileReaderUtility;

import javax.inject.Inject;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Dao {
    private static final Logger.ALogger LOG = Logger.of(Dao.class);

    private final EntityManagerProvider emp;
    private final FileReaderUtility sqlReader;
    private final Environment environment;

    @Inject
    public Dao(EntityManagerProvider emp,
               FileReaderUtility sqlReader,
               Environment environment) {
        this.emp = emp;
        this.sqlReader = sqlReader;
        this.environment = environment;
    }

    public final String executeUpdate(final String script) {
        final String sqlFilePath = "test-script" + File.separatorChar + script;

        InputStream inputStream = environment.resourceAsStream(sqlFilePath);

        try {
            final BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));
            for (String sqlString = br.readLine(); sqlString != null; sqlString = br.readLine()) {
                LOG.info("Executing SQL string - " +sqlString);
                emp.getEntityManager().createNativeQuery(sqlString).executeUpdate();
            }
            LOG.info("Query execution completed successfully - " +script);
            return "Query executed successfully";

        } catch (Exception e) {
            LOG.error("Error executing update SQL", e);
            return e.getMessage();
        }
    }

    public final String executeQuery(final String script) {
        final String sqlFilePath = "test-script" + File.separatorChar + script;
        LOG.info("SQL File Path: " + sqlFilePath);
        try {
            final String sqlString = sqlReader.readFile(sqlFilePath);
            return emp.getEntityManager().createNativeQuery(sqlString).getSingleResult().toString();
        } catch (Exception e) {
            LOG.error("Error executing query SQL", e);
            return e.getMessage();
        }
    }

}
