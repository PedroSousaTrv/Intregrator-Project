import java.util.Scanner;
public class ServicoLogin {
    private String email;
    private String senha;
    private RepositorioEstudante rep;
    public ServicoLogin(RepositorioEstudante repositorioCompartilhado) {
        this.rep = repositorioCompartilhado;
    }
    private Scanner sc = new Scanner(System.in);
    void servicoLogin() {
        System.out.println("========== BEM-VINDO(A) DE VOLTA ==========");
        System.out.println("E-mail:");
        email = sc.nextLine();
        Estudante estudante = rep.buscarPorEmail(email);
        if (estudante == null) {
            System.out.println("E-mail não cadastrado.");
            return;
        }
        System.out.println("Senha:");
        senha = sc.nextLine();
        if (estudante.getSenha().equals(senha)) {
            System.out.println("Login realizado com sucesso!");
            System.out.println("Olá, " + estudante.getNomeCompleto() + "! Seja bem-vindo ao sistema.");
        } else {
            System.out.println("Senha incorreta! Login cancelado.");
        }
    }
}

