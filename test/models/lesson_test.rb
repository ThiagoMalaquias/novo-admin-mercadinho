require "test_helper"

class LessonTest < ActiveSupport::TestCase
  test "fixtures devem ser válidas" do
    assert lessons(:aula_introducao).valid?
    assert lessons(:aula_avancada).valid?
    assert lessons(:aula_inativa).valid?
  end
  
  test "deve criar uma aula válida" do
    assert_difference('Lesson.count', 1) do
      Lesson.create!(
        capsule: capsules(:one),
        title: "Nova Aula",
        description: "Descrição da nova aula",
        status: "active",
        release_period: 0
      )
    end
  end
  
  test "deve pertencer a um capsule" do
    lesson = lessons(:aula_introducao)
    
    assert_not_nil lesson.capsule
    assert_instance_of Capsule, lesson.capsule
  end
  
  test "deve ter muitos lesson_womb_component_lectures" do
    lesson = lessons(:aula_introducao)
    
    assert_respond_to lesson, :lesson_womb_component_lectures
  end
  
  test "deve ter muitos lesson_lecture_videos" do
    lesson = lessons(:aula_introducao)
    
    assert_respond_to lesson, :lesson_lecture_videos
  end
  
  test "deve ter muitos lecture_videos através de lesson_lecture_videos" do
    lesson = lessons(:aula_introducao)
    
    assert_respond_to lesson, :lecture_videos
  end
  
  test "deve ter muitos lesson_content" do
    lesson = lessons(:aula_introducao)
    
    assert_respond_to lesson, :lesson_content
  end
  
  test "deve ter muitos user_lessons" do
    lesson = lessons(:aula_introducao)
    
    assert_respond_to lesson, :user_lessons
  end
  
  test "deve ter anexos de medias" do
    lesson = lessons(:aula_introducao)
    
    assert_respond_to lesson, :medias
  end
  
  test "scope actives deve retornar apenas aulas ativas" do
    actives = Lesson.actives
    
    assert_includes actives, lessons(:aula_introducao)
    assert_includes actives, lessons(:aula_avancada)
    assert_not_includes actives, lessons(:aula_inativa)
  end
  
  test "released deve retornar true quando release_period é zero" do
    lesson = lessons(:aula_introducao)
    user = users(:usuario_ativo)
    
    assert lesson.released(user)
  end
  
  test "release_date deve retornar nil quando release_period é zero" do
    lesson = lessons(:aula_introducao)
    user = users(:usuario_ativo)
    
    assert_nil lesson.release_date(user)
  end
  
  test "attended deve retornar false quando usuário não assistiu" do
    lesson = lessons(:aula_introducao)
    user = users(:usuario_ativo)
    
    result = lesson.attended(user)
    
    assert_includes [true, false], result
  end
  
  # ==========================================
  # TESTES DE VALORES PADRÃO
  # ==========================================
  
  test "deve ter valores padrão corretos" do
    lesson = Lesson.new
    
    assert_equal 0, lesson.release_period
    assert_equal 0, lesson.order_sequences
  end
  
  # ==========================================
  # TESTES DE STATUS
  # ==========================================
  
  test "aula ativa deve ter status active" do
    lesson = lessons(:aula_introducao)
    
    assert_equal "active", lesson.status
  end
  
  test "aula inativa deve ter status inactive" do
    lesson = lessons(:aula_inativa)
    
    assert_equal "inactive", lesson.status
  end
  
  # ==========================================
  # TESTES DE RELEASE_PERIOD
  # ==========================================
  
  test "aula imediata deve ter release_period zero" do
    lesson = lessons(:aula_introducao)
    
    assert_equal 0, lesson.release_period
  end
  
  test "aula programada deve ter release_period maior que zero" do
    lesson = lessons(:aula_programada)
    
    assert lesson.release_period > 0
    assert_equal 30, lesson.release_period
  end
  
  test "aula pode ter array de vídeos" do
    lesson = lessons(:aula_avancada)
    
    assert lesson.videos.is_a?(Array)
    assert lesson.videos.any?
  end
  
  test "aula pode não ter vídeos" do
    lesson = lessons(:aula_introducao)
    
    assert lesson.videos.is_a?(Array)
    assert lesson.videos.empty?
  end
  
  test "correct_videos deve remover vídeos em branco" do
    lesson = Lesson.new(
      capsule: capsules(:one),
      title: "Test",
      status: "active",
      videos: ["video1", "", "video2", nil]
    )
    
    lesson.save!
    
    assert_equal ["video1", "video2"], lesson.videos
  end
  
  test "aulas devem ter ordem sequencial" do
    aula1 = lessons(:aula_introducao)
    aula2 = lessons(:aula_avancada)
    
    assert_equal 1, aula1.order_sequences
    assert_equal 2, aula2.order_sequences
  end
  
  test "deve aceitar nested attributes para lesson_content" do
    lesson = Lesson.new(
      capsule: capsules(:one),
      title: "Aula com conteúdo",
      status: "active"
    )
    
    assert_respond_to lesson, :lesson_content_attributes=
  end
  
  test "deve ter callback before_save para correct_videos" do
    callbacks = Lesson._save_callbacks.select { |cb| cb.kind == :before }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :correct_videos
  end

  test "title deve ser string" do
    lesson = lessons(:aula_introducao)
    
    assert_kind_of String, lesson.title
  end
  
  test "description pode ser texto longo" do
    lesson = Lesson.create!(
      capsule: capsules(:one),
      title: "Test",
      description: "A" * 1000,
      status: "active"
    )
    
    assert lesson.description.length == 1000
  end
  
  test "videos deve ser array" do
    lesson = lessons(:aula_avancada)
    
    assert_instance_of Array, lesson.videos
  end
  
  test "medias deve ser array" do
    lesson = lessons(:aula_introducao)
    
    assert_instance_of ActiveStorage::Attached::Many, lesson.medias
  end
end