import java.lang.classfile.instruction.SwitchCase;
import java.util.Scanner;


public class ServicoCadastro {
    public String nome;
    public String email;
    public String curso;
    public int periodo;
    public String senha;
    public String confirmar;

    // Removemos o "= new RepositorioEstudante()" daqui
    private RepositorioEstudante rep;

    // CONSTRUTOR: Exige o repositório centralizado ao ser criado
    public ServicoCadastro(RepositorioEstudante repositorioCompartilhado) {
        this.rep = repositorioCompartilhado;
    }


    public void servicoCadastro() {
        System.out.println("========== CRIAR CONTA ==========");
        Scanner sc = new Scanner(System.in);

        System.out.println("Nome completo:");
        nome = sc.nextLine();

        while(true) {
        System.out.println("E-mail institucional:");
        email = sc.nextLine();

            if (email.contains("@") && email.endsWith("edu.br")) {
                break;
            }else{
                    System.out.println("E-mail invalido! tente novamente.");

            }
        }

        System.out.println("Curso:");
        curso = sc.nextLine();

        System.out.println("Periodo:");
        periodo = sc.nextInt();
        sc.nextLine();

        while(true) {
            System.out.println("========Requisitos para senha========");
            System.out.println("-Pelo menos 8 caracteres");
            System.out.println("-Pelo menos 1 numero");
            System.out.println("-Pelo menos 1 letra maiuscula");
            System.out.println("Crie sua senha:");
            senha = sc.nextLine();
            boolean tamanhoValido = senha.length() >=8;
            boolean numValido = senha.matches(".*//d.*");
            boolean letraMaiuscula = senha.matches(".*[A-Z].*");

            if(!tamanhoValido) System.out.println("A senha deve possuir ao menos 8 caracteres");
            if(!numValido) System.out.println("A senha deve possuir ao menos 1 numero");
            if(!letraMaiuscula) System.out.println("A senha deve possuir ao menos 1 letra maiuscula");

            System.out.println("Confirmar senha:");
            confirmar = sc.nextLine();

            if (confirmar.equals(senha)) {
                System.out.println("Senha confirmada.");
                break;
            } else {
                System.out.println("Senha incorreta, tente novamente.");

            }

        }
        Estudante novoEstudante = new Estudante(nome, email,curso, periodo, senha);
        boolean cadastrou = rep.adicionar(novoEstudante);
        if(cadastrou) System.out.println("Cadastro realizado com sucesso!");
        else System.out.println("Erro! E-mail ja cadastrado.");


        }
    }



