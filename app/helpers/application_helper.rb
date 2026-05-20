module ApplicationHelper
  include Pagy::Frontend

  CURRENCIES = %w[USD EUR GBP CAD AUD INR JPY CHF SGD AED].freeze

  # Formats a numeric amount as currency using money-rails for symbols/precision.
  def money(amount, currency = current_user&.default_currency || "USD")
    Money.from_amount(amount.to_d, currency).format
  rescue Money::Currency::UnknownCurrency
    number_to_currency(amount.to_d)
  end

  # Short money format without decimals — handy for big dashboard figures.
  def money_short(amount, currency = current_user&.default_currency || "USD")
    Money.from_amount(amount.to_d, currency).format(no_cents: true)
  rescue Money::Currency::UnknownCurrency
    number_to_currency(amount.to_d, precision: 0)
  end

  def currency_options
    CURRENCIES.map { |c| ["#{c} — #{Money::Currency.new(c).symbol}", c] }
  end

  # Renders a coloured status pill.
  def status_pill(text, classes)
    content_tag :span, text.to_s.titleize,
                class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold #{classes}"
  end

  def nav_link_to(name, path, icon: nil, exact: false)
    active = exact ? current_page?(path) : request.path.start_with?(path) && path != "/"
    base = "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition group"
    state = active ? "bg-indigo-600 text-white shadow-sm" : "text-slate-300 hover:bg-slate-800 hover:text-white"
    link_to path, class: "#{base} #{state}" do
      concat content_tag(:span, icon&.html_safe, class: "w-5 h-5 flex-shrink-0") if icon
      concat content_tag(:span, name)
    end
  end

  def flash_classes(level)
    {
      "notice"  => "bg-emerald-50 text-emerald-800 border-emerald-200",
      "success" => "bg-emerald-50 text-emerald-800 border-emerald-200",
      "alert"   => "bg-red-50 text-red-800 border-red-200",
      "error"   => "bg-red-50 text-red-800 border-red-200"
    }[level.to_s] || "bg-slate-50 text-slate-800 border-slate-200"
  end

  def avatar_initials(name, classes: "w-10 h-10 text-sm")
    initials = name.to_s.split.map(&:first).first(2).join.upcase
    content_tag :div, initials,
                class: "#{classes} rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 text-white font-semibold flex items-center justify-center flex-shrink-0"
  end
end
