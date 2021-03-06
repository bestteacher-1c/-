Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.Проводки.Записывать = Истина;
	Движения.Проводки.БлокироватьДляИзменения = Истина;
	
	Движение = Движения.Проводки.Добавить();
	
	Движение.Период = Дата;
	Движение.Организация = Организация;
	Движение.Сумма = Сумма;
	Движение.СодержаниеПроводки = "Поступили денежные средства";
	
	Движение.СчетДт = КорСчет;
	
	Движение.СчетКт = МестоХраненияДенежныхСредств.СчетУчета;
	
	Движения.Записать();
	
    //-------Проверка остатка -----
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПроводкиОстатки.СуммаОстатокДт
	|ИЗ
	|	РегистрБухгалтерии.Проводки.Остатки(&Период, Счет = &СчетУчетаДС, Организация = &Организация) КАК ПроводкиОстатки
	|ГДЕ
	|	ПроводкиОстатки.СуммаОстатокДт < 0";
	
	СчетУчетаДС = МестоХраненияДенежныхСредств.СчетУчета;
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Период", Новый Граница(МоментВремени(), ВидГраницы.Включая) );
	Запрос.УстановитьПараметр("СчетУчетаДС", СчетУчетаДС);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Количество() > 0 Тогда
		
		Отказ = Истина;
		
		ВыборкаДетальныеЗаписи.Следующий();
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Нехватает денежных средств. Нехвакта " + ВыборкаДетальныеЗаписи.СуммаОстатокДт;
		Сообщение.Поле = "Сумма";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
	
	КонецЕсли;

КонецПроцедуры
