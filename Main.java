import java.sql.SQLException;
import java.util.Scanner;

/**
 * Ponto de entrada. Se as variáveis SONAR_DB_URL, SONAR_DB_USER e SONAR_DB_PASSWORD
 * estiverem definidas, usa o banco de dados; senão, roda em memória.
 */
public class Main {

    public static void main(String[] args) {
        Entrada entrada = new Entrada(new Scanner(System.in)); // único Scanner do programa (F-11)
        RepositorioEstudante rep = criarRepositorio();
        if (rep == null) {
            return;
        }
        MenuPrincipal menu = new MenuPrincipal(entrada);
        ServicoCadastro cadastro = new ServicoCadastro(rep, entrada);
        ServicoLogin login = new ServicoLogin(rep, entrada);
        System.out.println("Iniciando o sistema...");

        try {
            while (true) {
                int opcao = menu.menuPrin();
                if (opcao == 0) {
                    System.out.println("Ate logo!");
                    return;
                }
                try {
                    if (opcao == 1) cadastro.servicoCadastro();
                    else login.servicoLogin();
                } catch (IllegalStateException e) {
                    System.out.println("Erro de acesso aos dados. Tente novamente mais tarde.");
                }
            }
        } catch (Entrada.FimDaEntrada e) {
            System.out.println("Entrada encerrada. Ate logo!");
        }
    }

    private static RepositorioEstudante criarRepositorio() {
        String url = System.getenv("SONAR_DB_URL");
        if (url == null || url.isBlank()) {
            System.out.println("[Aviso] Banco nao configurado: rodando em memoria, os dados nao serao salvos.");
            return new RepositorioEstudanteMemoria();
        }
        RepositorioEstudanteJdbc jdbc = new RepositorioEstudanteJdbc(url,
                System.getenv("SONAR_DB_USER"), System.getenv("SONAR_DB_PASSWORD"));
        try {
            jdbc.testarConexao();
            System.out.println("[Info] Conectado ao banco de dados.");
            return jdbc;
        } catch (SQLException e) {
            System.out.println("Nao foi possivel conectar ao banco: " + e.getMessage());
            return null;
        }
    }
}
