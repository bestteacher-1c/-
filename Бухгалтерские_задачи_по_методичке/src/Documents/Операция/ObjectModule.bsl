

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если (Движения.Проводки.Количество() > 0) Тогда
		Для Каждого Проводка Из Движения.Проводки Цикл
			
			Проводка.Период = Дата;
			Проводка.Организация = Организация;
			
		КонецЦикла;
	КонецЕсли;
	
	Если (ЭтоНовый() = Ложь И Ссылка.ПометкаУдаления <> ПометкаУдаления) Тогда
		
		Движения.Проводки.Записывать = Истина;
		Движения.Проводки.Прочитать();
		Движения.Проводки.УстановитьАктивность(Не ПометкаУдаления);
		
	КонецЕсли;
	

КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	ОбъектКопирования.Движения.Прочитать();

	Для Каждого ИсхЗапись Из ОбъектКопирования.Движения Цикл
		
		Проводка = Движения.Проводки.Добавить();
		ЗаполнитьЗначенияСвойств(Проводка, ИсхЗапись);
		
	КонецЦикла;
	

КонецПроцедуры

