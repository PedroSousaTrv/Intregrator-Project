import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Repositório que grava no banco via JDBC (corrige F-10).
 * Funciona com MySQL/MariaDB e PostgreSQL, pois usa só SQL padrão e consultas parametrizadas
 * (PreparedStatement), o que também evita injeção de SQL.
 */
public class RepositorioEstudanteJdbc implements RepositorioEstudante {

    private final String url;
    private final String usuario;
    private final String senha;

    public RepositorioEstudanteJdbc(String url, String usuario, String senha) {
        this.url = url;
        this.usuario = usuario;
        this.senha = senha;
    }

    private Connection conectar() throws SQLException {
        return DriverManager.getConnection(url, usuario, senha);
    }

    /** Testa a conexão na inicialização, para o erro aparecer logo. */
    public void testarConexao() throws SQLException {
        try (Connection c = conectar()) {
            c.isValid(2);
        }
    }

    @Override
    public Integer buscarInstituicaoPorDominio(String dominio) {
        String sql = "SELECT id_instituicao FROM INSTITUICAO WHERE dominio_email = ?";
        try (Connection c = conectar(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, dominio);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Erro ao consultar instituicao", e);
        }
    }

    @Override
    public boolean emailExiste(String emailNormalizado) {
        return buscarPorEmail(emailNormalizado) != null;
    }

    @Override
    public Estudante buscarPorEmail(String emailNormalizado) {
        String sql = "SELECT id_estudante, id_instituicao, nome, email, curso, periodo, senha_hash "
                + "FROM ESTUDANTE WHERE email = ?";
        try (Connection c = conectar(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, emailNormalizado);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return new Estudante(rs.getInt("id_estudante"), rs.getInt("id_instituicao"),
                        rs.getString("nome"), rs.getString("email"), rs.getString("curso"),
                        rs.getInt("periodo"), rs.getString("senha_hash"));
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Erro ao buscar estudante", e);
        }
    }

    @Override
    public boolean adicionar(Estudante est) {
        String sql = "INSERT INTO ESTUDANTE (id_instituicao, nome, email, curso, periodo, senha_hash) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = conectar();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, est.getIdInstituicao());
            ps.setString(2, est.getNomeCompleto());
            ps.setString(3, est.getEmailInstitucional());
            ps.setString(4, est.getCurso());
            ps.setInt(5, est.getPeriodo());
            ps.setString(6, est.getSenhaHash());
            ps.executeUpdate();
            try (ResultSet chaves = ps.getGeneratedKeys()) {
                if (chaves.next()) {
                    est.setIdEstudante(chaves.getInt(1));
                }
            }
            return true;
        } catch (SQLException e) {
            // SQLState 23xxx = violação de restrição (ex.: e-mail UNIQUE já existente)
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                return false;
            }
            throw new IllegalStateException("Erro ao gravar estudante", e);
        }
    }
}
