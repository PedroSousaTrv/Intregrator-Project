import java.util.List;

/** Fluxo de criação de conta (RF-001). Só avança quando cada regra é cumprida. */
public class ServicoCadastro {

    private final RepositorioEstudante rep;
    private final Entrada entrada;

    public ServicoCadastro(RepositorioEstudante rep, Entrada entrada) {
        this.rep = rep;
        this.entrada = entrada;
    }

    public void servicoCadastro() {
        System.out.println("========== CRIAR CONTA ==========");

        String nome;
        while (true) {
            nome = entrada.lerTexto("Nome completo:").trim();
            if (Validador.nomeValido(nome)) break;
            System.out.println("Nome invalido. Informe ao menos 3 caracteres.");
        }

        String email;
        int idInstituicao;
        while (true) {
            email = Validador.normalizarEmail(entrada.lerTexto("E-mail institucional:"));
            if (!Validador.emailValido(email)) {
                System.out.println("E-mail invalido! Use seu e-mail institucional (exemplo: nome@instituicao.edu.br).");
                continue;
            }
            Integer id = rep.buscarInstituicaoPorDominio(Validador.dominio(email));
            if (id == null) {
                System.out.println("Sua instituicao ainda nao utiliza a plataforma.");
                continue;
            }
            if (rep.emailExiste(email)) {
                System.out.println("Erro! E-mail ja cadastrado. Use a opcao [2] para entrar.");
                return;
            }
            idInstituicao = id;
            break;
        }

        String curso;
        while (true) {
            curso = entrada.lerTexto("Curso:").trim();
            if (curso.length() >= 2) break;
            System.out.println("Curso invalido.");
        }

        int periodo = entrada.lerInteiro("Periodo (1 a 10):", 1, 10);

        String senha;
        while (true) {
            System.out.println("========Requisitos para senha========");
            System.out.println("-Pelo menos 8 caracteres");
            System.out.println("-Pelo menos 1 numero");
            System.out.println("-Pelo menos 1 letra maiuscula e 1 minuscula");
            senha = entrada.lerTexto("Crie sua senha:");
            List<String> problemas = Validador.problemasSenha(senha);
            if (!problemas.isEmpty()) {
                problemas.forEach(System.out::println);
                System.out.println("Tente novamente.");
                continue; // não deixa avançar com senha fraca (corrige F-02)
            }
            String confirmar = entrada.lerTexto("Confirmar senha:");
            if (confirmar.equals(senha)) {
                System.out.println("Senha confirmada.");
                break;
            }
            System.out.println("As senhas nao conferem, tente novamente.");
        }

        Estudante novo = new Estudante(null, idInstituicao, nome, email, curso, periodo, SenhaHash.gerar(senha));
        if (rep.adicionar(novo)) {
            System.out.println("Cadastro realizado com sucesso!");
        } else {
            System.out.println("Erro! E-mail ja cadastrado.");
        }
    }
}
