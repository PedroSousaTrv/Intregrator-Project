/** Menu principal. Opção inválida ou texto não encerram o programa (corrige F-07). */
public class MenuPrincipal {

    private final Entrada entrada;

    public MenuPrincipal(Entrada entrada) {
        this.entrada = entrada;
    }

    public int menuPrin() {
        System.out.println("==========Menu Principal==========");
        System.out.println("[1] Criar conta");
        System.out.println("[2] Ja tenho conta");
        System.out.println("[0] Sair");
        return entrada.lerInteiro("Escolha uma opcao:", 0, 2);
    }
}
