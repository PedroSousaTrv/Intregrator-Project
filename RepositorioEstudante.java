/**
 * Contrato de acesso aos dados de estudantes.
 * Há duas implementações: em memória (testes rápidos) e JDBC (banco de dados, corrige F-10).
 * O repositório não imprime mensagens; quem fala com o usuário são os serviços (corrige F-08).
 */
public interface RepositorioEstudante {

    /** Id da instituição contratante dona do domínio de e-mail, ou null se não for contratante (RNE-001). */
    Integer buscarInstituicaoPorDominio(String dominio);

    boolean emailExiste(String emailNormalizado);

    /** Estudante com o e-mail informado, ou null se não existir. */
    Estudante buscarPorEmail(String emailNormalizado);

    /** Grava o estudante. Retorna false se o e-mail já estiver cadastrado. */
    boolean adicionar(Estudante estudante);
}
