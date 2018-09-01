Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	
	//проверка вынесена в подписку на события
	
	//Если ПолучитьФункциональнуюОпцию("УчетПоПодразделениям"
	//	, Новый Структура("ПФО_Организация", Организация)) = Ложь Тогда
	//
	//	  Индекс = ПроверяемыеРеквизиты.Найти("Подразделение");
	//		ПроверяемыеРеквизиты.Удалить(Индекс);
	//		
	//
	//КонецЕсли;                      
	
	Если ПолучитьФункциональнуюОпцию("ВалютныйУчет"
		, Новый Структура("ПФО_Организация", Организация)) = Ложь Тогда
	
		  Индекс = ПроверяемыеРеквизиты.Найти("Валюта");
			ПроверяемыеРеквизиты.Удалить(Индекс);
			
	
	КонецЕсли;                      
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.Проводки.Записывать = Истина;
	Движения.Проводки.БлокироватьДляИзменения = Истина;
	
	Движение = Движения.Проводки.Добавить();
	
	Движение.Период = Дата;
	Движение.Организация = Организация;
	Движение.Сумма = Сумма;
	Движение.СодержаниеПроводки = "Выплатили денежные средства";
	
	Движение.СчетДт = КорСчет;
	Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение, Подразделение, "Дт");
	Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение,1,КорСубконто1,"Дт");
	Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение,2,КорСубконто2,"Дт");
	Бухгалтерия.ЗаполнитьВалютуСтороныПроводки(Движение,Валюта, Сумма,"Дт");
	
	Движение.СчетКт = ?(Наличные, ПланыСчетов.Счета.Касса, ПланыСчетов.Счета.СчетВБанке);
	Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение, Подразделение, "Кт");
	Бухгалтерия.ЗаполнитьВалютуСтороныПроводки(Движение,Валюта, Сумма,"Кт");
	Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение,"ДвиженияДенежныхСредств",ДДС,"Кт");
	
	Бухгалтерия.СформироватьПроводкиКурсовыеРазницы(Движение, Движения.Проводки, "Дт");
	Бухгалтерия.СформироватьПроводкиКурсовыеРазницы(Движение, Движения.Проводки, "Кт");
	
	Движения.Записать();
	
    //-------Проверка остатка -----
	
	Запрос = Новый Запрос;
	
	//Если Движение.СчетКт.ПоПодразделениям Тогда
	//
	//	Запрос.Текст = 
	//	"ВЫБРАТЬ
	//	|	ПроводкиОстатки.СуммаОстатокДт
	//	|ИЗ
	//	|	РегистрБухгалтерии.Проводки.Остатки(
	//	|			&Период,
	//	|			Счет = &СчетУчетаДС,
	//	|			,
	//	|			Организация = &Организация
	//	|				И Подразделение = &Подразделение) КАК ПроводкиОстатки
	//	|ГДЕ
	//	|	ПроводкиОстатки.СуммаОстатокДт < 0";
	//
	//Иначе
	
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПроводкиОстатки.СуммаОстатокДт
		|ИЗ
		|	РегистрБухгалтерии.Проводки.Остатки(&Период, Счет = &СчетУчетаДС, , Организация = &Организация) КАК ПроводкиОстатки
		|ГДЕ
		|	ПроводкиОстатки.СуммаОстатокДт < 0";
		
	
	//КонецЕсли;
	
	
	ИзменитьТекстЗапроса(Запрос, Движение.СчетКт);
	
	
	СчетУчетаДС = ?(Наличные, ПланыСчетов.Счета.Касса, ПланыСчетов.Счета.СчетВБанке);
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Период", Новый Граница(МоментВремени(), ВидГраницы.Включая) );
	Запрос.УстановитьПараметр("СчетУчетаДС", СчетУчетаДС);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Количество() > 0 Тогда
		
		Отказ = Истина;
		
		ВыборкаДетальныеЗаписи.Следующий();
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Нехватает денежных средств. Нехвакта "
		+ ?(Движение.СчетКт.Валютный
		,ВыборкаДетальныеЗаписи.СуммаВалютыОстатокДт
		,ВыборкаДетальныеЗаписи.СуммаОстатокДт) + " " + Валюта;
		
		Сообщение.Поле = "Сумма";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
	
	КонецЕсли;

КонецПроцедуры

Процедура ИзменитьТекстЗапроса(Запрос, Счет)
	
	СхемаЗапроса = Новый СхемаЗапроса;
	
	СхемаЗапроса.УстановитьТекстЗапроса(Запрос.Текст);
	
	Если Счет.ПоПодразделениям Тогда
		
		Таблица_Из = СхемаЗапроса.ПакетЗапросов.Получить(0).Операторы.Получить(0).Источники.Получить(0);
		
		УсловиеНаИзмерение = Строка(Таблица_Из.Источник.Параметры.Получить(3).Выражение);
		
		Таблица_Из.Источник.Параметры.Получить(3).Выражение =
		Новый ВыражениеСхемыЗапроса("" + УсловиеНаИзмерение + " И Подразделение = &Подразделение");
		
		
		
		Запрос.УстановитьПараметр("Подразделение", Подразделение);
		
		
	КонецЕсли;
	
	Если Счет.Валютный Тогда
		
		Таблица_Из = СхемаЗапроса.ПакетЗапросов.Получить(0).Операторы.Получить(0).Источники.Получить(0);
		
		УсловиеНаИзмерение = Строка(Таблица_Из.Источник.Параметры.Получить(3).Выражение);
		
		Таблица_Из.Источник.Параметры.Получить(3).Выражение =
		Новый ВыражениеСхемыЗапроса("" + УсловиеНаИзмерение + " И Валюта = &Валюта");
		
		СхемаЗапроса.ПакетЗапросов[0].Операторы[0].ВыбираемыеПоля.Установить(0,
		Новый ВыражениеСхемыЗапроса("ПроводкиОстатки.СуммаВалютыОстатокДт"));
		
		СхемаЗапроса.ПакетЗапросов.Получить(0).Операторы.Получить(0).Отбор.Установить(0,
		Новый ВыражениеСхемыЗапроса("ПроводкиОстатки.СуммаВалютыОстатокДт < 0"));
		
		
		Запрос.УстановитьПараметр("Валюта", Валюта);
	
		
	КонецЕсли;
	
	Запрос.Текст = СхемаЗапроса.ПолучитьТекстЗапроса();
	
КонецПроцедуры


