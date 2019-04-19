Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ПолучитьФункциональнуюОпцию("УчетПоПодразделениям"
		, Новый Структура("ПФО_Организация", Организация)) = Ложь Тогда
	
		  Индекс = ПроверяемыеРеквизиты.Найти("Подразделение");
			ПроверяемыеРеквизиты.Удалить(Индекс);
			
	
	КонецЕсли;                      
	
	Если ПолучитьФункциональнуюОпцию("ВалютныйУчет"
		, Новый Структура("ПФО_Организация", Организация)) = Ложь Тогда
	
		  Индекс = ПроверяемыеРеквизиты.Найти("Валюта");
			ПроверяемыеРеквизиты.Удалить(Индекс);
			
	
	КонецЕсли;                      
	
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.Проводки.Записывать = Истина;
	
	Движение = Движения.Проводки.Добавить();
	
	Движение.Период = Дата;
	Движение.Организация = Организация;
	Движение.Сумма = СерверныйСВызовом.ПересчитатьИзВалютыВВалюту(Валюта,,Сумма,Дата);;
	Движение.СодержаниеПроводки = "Поступили денежные средства";
	
	Движение.СчетДт = ?(Наличные,ПланыСчетов.Счета.Касса, ПланыСчетов.Счета.СчетВБанке);
	Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение,Подразделение,"Дт");
	Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение,"ДвиженияДенежныхСредств",ДДС,"Дт");
//	Бухгалтерия.ЗаполнитьВалютуСтороныПроводки(Движение,Валюта, Сумма,"Дт");

	
	Движение.СчетКт = КорСчет;
	Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение,1,КорСубконто1,"Кт");
	Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение,2,КорСубконто2,"Кт");
	Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение,Подразделение,"Кт");
//	Бухгалтерия.ЗаполнитьВалютуСтороныПроводки(Движение,Валюта, Сумма,"Кт");
	
	
КонецПроцедуры
