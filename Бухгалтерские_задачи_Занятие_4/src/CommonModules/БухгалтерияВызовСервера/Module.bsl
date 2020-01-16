
Функция ПолучитьСчетУчетаНоменклатуры(Номенклатура, Организация) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СчетаУчетаНоменклатуры.СчетУчета,
	|	СчетаУчетаНоменклатуры.Организация,
	|	СчетаУчетаНоменклатуры.Номенклатура
	|ПОМЕСТИТЬ ВТДанные
	|ИЗ
	|	РегистрСведений.СчетаУчетаНоменклатуры КАК СчетаУчетаНоменклатуры
	|ГДЕ
	|	СчетаУчетаНоменклатуры.Организация В (&Организация, &ПустаяОрганизация)
	|	И СчетаУчетаНоменклатуры.Номенклатура В (&ПустаяНоменклатура, &Номенклатура)
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТДанные.СчетУчета
	|ИЗ
	|	ВТДанные КАК ВТДанные
	|ГДЕ
	|	ВТДанные.Номенклатура = &Номенклатура
	|	И ВТДанные.Организация = &Организация
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТДанные.СчетУчета
	|ИЗ
	|	ВТДанные КАК ВТДанные
	|ГДЕ
	|	ВТДанные.Номенклатура = &Номенклатура
	|	И ВТДанные.Организация = &ПустаяОрганизация
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТДанные.СчетУчета
	|ИЗ
	|	ВТДанные КАК ВТДанные
	|ГДЕ
	|	ВТДанные.Номенклатура = &ПустаяНоменклатура
	|	И ВТДанные.Организация = &Организация
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТДанные.СчетУчета
	|ИЗ
	|	ВТДанные КАК ВТДанные
	|ГДЕ
	|	ВТДанные.Номенклатура = &ПустаяНоменклатура
	|	И ВТДанные.Организация = &ПустаяОрганизация";
	
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ПустаяНоменклатура", Справочники.Номенклатура.ПустаяСсылка());
	Запрос.УстановитьПараметр("ПустаяОрганизация", Справочники.Организации.ПустаяСсылка());
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл

		Возврат ВыборкаДетальныеЗаписи.СчетУчета;
		
	КонецЦикла;

	Возврат ПланыСчетов.Счета.ПустаяСсылка();
	
КонецФункции // ПолучитьСчетУчетаНоменклатуры()

Функция ПересчитатьИзВалютыВВалюту(ВалютаИЗ, ВалютаВ, СуммаИз, Дата) Экспорт

	Если СуммаИз = 0 Тогда
		Возврат 0;
	КонецЕсли;

Если ВалютаИЗ = Неопределено Или ВалютаИЗ = Справочники.Валюты.ПустаяСсылка() Тогда
		ВалютаИЗ = Справочники.Валюты.РубльРФ;
	КонецЕсли;

	Если ВалютаВ = Неопределено Или ВалютаИЗ = Справочники.Валюты.ПустаяСсылка() Тогда
		ВалютаВ = Справочники.Валюты.РубльРФ;
	КонецЕсли;

	Если ВалютаВ = ВалютаИЗ Тогда
		Возврат СуммаИз;
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст = "	ВЫБРАТЬ
		|	СУММА(ВЫБОР
		|			КОГДА КурсыВалютСрезПоследних.Валюта = &ВалютаВ
		|				ТОГДА КурсыВалютСрезПоследних.Курс
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК КурсВ,
		|	СУММА(ВЫБОР
		|			КОГДА КурсыВалютСрезПоследних.Валюта = &ВалютаИз
		|				ТОГДА КурсыВалютСрезПоследних.Курс
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК КурсИз
		|ПОМЕСТИТЬ ВТИсходная
		|ИЗ
		|	РегистрСведений.КурсыВалют.СрезПоследних(&Дата, Валюта В (&ВалютаИз, &ВалютаВ)) КАК КурсыВалютСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫБОР ВТИсходная.КурсВ
		|		КОГДА 0
		|			ТОГДА 0
		|		ИНАЧЕ &СуммаИЗ * ВТИсходная.КурсИз / ВТИсходная.КурсВ
		|	КОНЕЦ КАК СуммаВ
		|ИЗ
		|	ВТИсходная КАК ВТИсходная";

	Запрос.УстановитьПараметр("ВалютаИЗ", ВалютаИЗ);
	Запрос.УстановитьПараметр("ВалютаВ", ВалютаВ);
	Запрос.УстановитьПараметр("СуммаИЗ", СуммаИЗ);
	Запрос.УстановитьПараметр("Дата", Дата);

	РезультатЗапроса = Запрос.Выполнить();

	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл

		Возврат ВыборкаДетальныеЗаписи.СуммаВ;

	КонецЦикла;

	Возврат 0;

КонецФункции

Функция ПолучитьСвойствоСчета(Счет) Экспорт

	ДанныеСчета = Новый Структура;
	
	МаксКоличествоСубконто = Метаданные.ПланыСчетов.Счета.МаксКоличествоСубконто;

	ДанныеСчета.Вставить("МаксКоличествоСубконто", МаксКоличествоСубконто);


	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	СчетаВидыСубконто.Ссылка.Забалансовый,
	|	СчетаВидыСубконто.Ссылка.ПоПодразделениям,
	|	СчетаВидыСубконто.Ссылка КАК Ссылка,
	|	СчетаВидыСубконто.ВидСубконто КАК ВидСубконто,
	|	СчетаВидыСубконто.ВидСубконто.Наименование,
	|	СчетаВидыСубконто.ВидСубконто.ИмяПредопределенныхДанных,
	|	СчетаВидыСубконто.ВидСубконто.ТипЗначения
	|ИЗ
	|	ПланСчетов.Счета.ВидыСубконто КАК СчетаВидыСубконто
	|ГДЕ
	|	СчетаВидыСубконто.Ссылка = &Ссылка
	|ИТОГИ
	|	КОЛИЧЕСТВО(ВидСубконто)
	|ПО
	|	Ссылка";

	Запрос.УстановитьПараметр("Ссылка", Счет);

	РезультатЗапроса = Запрос.Выполнить();

	ВыборкаСсылка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);

	Пока ВыборкаСсылка.Следующий() Цикл

		ДанныеСчета.Вставить("Забалансовый", ВыборкаСсылка.Забалансовый);
		ДанныеСчета.Вставить("ПоПодразделениям", ВыборкаСсылка.ПоПодразделениям);
		ДанныеСчета.Вставить("КоличествоСубконто", ВыборкаСсылка.ВидСубконто);


		ВыборкаДетальныеЗаписи = ВыборкаСсылка.Выбрать();

		Для Индекс = 1 По МаксКоличествоСубконто Цикл

			Если ВыборкаДетальныеЗаписи.Следующий() = Истина Тогда

				ДанныеСчета.Вставить("ВидСубконто"
					+ Индекс, ВыборкаДетальныеЗаписи.ВидСубконто);
				ДанныеСчета.Вставить("ВидСубконто" + Индекс
					+ "Наименование", ВыборкаДетальныеЗаписи.Наименование);
				ДанныеСчета.Вставить("ВидСубконто" + Индекс
					+ "ИмяПредопределенныхДанных", ВыборкаДетальныеЗаписи.ИмяПредопределенныхДанных);
				ДанныеСчета.Вставить("ВидСубконто" + Индекс
					+ "ТипЗначения", ВыборкаДетальныеЗаписи.ТипЗначения);

			Иначе

				ДанныеСчета.Вставить("ВидСубконто" + Индекс, Неопределено);
				ДанныеСчета.Вставить("ВидСубконто" + Индекс
					+ "Наименование", Неопределено);
				ДанныеСчета.Вставить("ВидСубконто" + Индекс
					+ "ИмяПредопределенныхДанных", Неопределено);
				ДанныеСчета.Вставить("ВидСубконто" + Индекс
					+ "ТипЗначения", Неопределено);

			КонецЕсли;

		КонецЦикла;

	КонецЦикла;



	Возврат ДанныеСчета;

КонецФункции

