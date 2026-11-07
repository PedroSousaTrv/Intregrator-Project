import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        RepositorioEstudante rep = new RepositorioEstudante();
        MenuPrincipal menu = new MenuPrincipal();
        ServicoCadastro cadastro = new ServicoCadastro(rep);
        ServicoLogin login =  new ServicoLogin(rep);
        System.out.println("Iniciando o sistema...");

        while (true) {
            menu.menuPrin();
            if (menu.value == 1)  cadastro.servicoCadastro();
            else if (menu.value == 2)  login.servicoLogin();
            else System.out.println("Opcao invalida, confira as opcoes no menu principal.");

        }

    }
}


