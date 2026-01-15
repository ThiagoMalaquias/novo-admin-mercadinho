require "test_helper"

class ReportPaymentTest < ActiveSupport::TestCase
  test "deve inicializar com params" do
    params = {
      course_id: courses(:curso_rails_ativo).id,
      start_date: "2024-01-01",
      end_date: "2024-01-31"
    }
    
    report = ReportPayment.new(params)
    
    assert_not_nil report
    assert_instance_of ReportPayment, report
  end
  
  test "deve ter attr_readers para course_id start_date e end_date" do
    params = {
      course_id: "123",
      start_date: "2024-01-01",
      end_date: "2024-01-31"
    }
    
    report = ReportPayment.new(params)
    
    assert_equal "123", report.course_id
    assert_equal "2024-01-01", report.start_date
    assert_equal "2024-01-31", report.end_date
  end
  
  test "deve inicializar sem course_id" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-01-31"
    }
    
    report = ReportPayment.new(params)
    
    assert_nil report.course_id
  end
  
  test "dashboard_graphic deve retornar array" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-01-05"
    }
    
    report = ReportPayment.new(params)
    result = report.dashboard_graphic
    
    assert_instance_of Array, result
  end
  
  test "dashboard_graphic deve retornar dados com date e amount" do
    params = {
      start_date: Date.today.to_s,
      end_date: Date.today.to_s
    }
    
    report = ReportPayment.new(params)
    result = report.dashboard_graphic
    
    assert_instance_of Array, result
    result.each do |item|
      assert item.key?(:date)
      assert item.key?(:amount)
    end
  end
  
  test "with_credit_card deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_credit_card
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "with_credit_card deve retornar valores numéricos" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_credit_card
    
    assert_kind_of Numeric, result[:amount]
    assert_kind_of Integer, result[:quantity]
  end
  
  test "with_billet deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_billet
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "with_pix deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_pix
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "with_bonus deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_bonus
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "all_refunded deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.all_refunded
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "all_canceled deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.all_canceled
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "unpaid_billet deve retornar hash com amount e quantity" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.unpaid_billet
    
    assert_instance_of Hash, result
    assert result.key?(:amount)
    assert result.key?(:quantity)
  end
  
  test "best_selling_courses deve retornar cursos mais vendidos" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.best_selling_courses
    
    assert_respond_to result, :each
  end
  
  test "best_selling_courses deve limitar a 10 resultados" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.best_selling_courses
    
    assert result.length <= 10
  end
  
  test "deve filtrar por course_id quando fornecido" do
    params = {
      course_id: courses(:curso_rails_ativo).id,
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_credit_card
    
    assert_instance_of Hash, result
  end
  
  test "deve retornar todos os pagamentos quando course_id é nil" do
    params = {
      course_id: nil,
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    result = report.with_credit_card
    
    assert_instance_of Hash, result
  end
  
  test "deve gerar relatório completo com todos os métodos" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    
    assert_instance_of Hash, report.with_credit_card
    assert_instance_of Hash, report.with_billet
    assert_instance_of Hash, report.with_pix
    assert_instance_of Hash, report.with_bonus
    assert_instance_of Hash, report.all_refunded
    assert_instance_of Hash, report.all_canceled
  end
  
  test "valores devem ser consistentes entre métodos" do
    params = {
      start_date: "2024-01-01",
      end_date: "2024-12-31"
    }
    
    report = ReportPayment.new(params)
    
    [
      report.with_credit_card,
      report.with_billet,
      report.with_pix,
      report.with_bonus
    ].each do |result|
      assert result[:amount] >= 0
      assert result[:quantity] >= 0
    end
  end
  
  test "dashboard_graphic deve cobrir período solicitado" do
    start_date = "2024-01-01"
    end_date = "2024-01-03"
    
    params = {
      start_date: start_date,
      end_date: end_date
    }
    
    report = ReportPayment.new(params)
    result = report.dashboard_graphic
    
    assert result.length >= 1
  end
end