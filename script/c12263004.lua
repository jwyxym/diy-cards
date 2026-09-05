--天水：洪川
local s,id=GetID()
function c12263004.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),2,99,s.lcheck)
	c:EnableReviveLimit()

	--① 特殊召唤成功时 检索天水
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12263004,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,12263004)
	e1:SetTarget(c12263004.thtg)
	e1:SetOperation(c12263004.thop)
	c:RegisterEffect(e1)

	--① 被破坏时 检索天水
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12263004,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,12263004)
	e2:SetCondition(c12263004.thcon)
	e2:SetTarget(c12263004.thtg)
	e2:SetOperation(c12263004.thop)
	c:RegisterEffect(e2)

	--② 墓地 连接/仪式特殊召唤 装备+可选回手
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12263004,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,122630041)
	e3:SetCondition(c12263004.eqcon)
	e3:SetTarget(c12263004.eqtg)
	e3:SetOperation(c12263004.eqop)
	c:RegisterEffect(e3)

	--③ 装备状态 效果发动时 破坏+仪式召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12263004,2))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,122630042)
	e4:SetCondition(c12263004.actcon)
	e4:SetTarget(c12263004.acttg)
	e4:SetOperation(c12263004.actop)
	c:RegisterEffect(e4)

	--装备限制
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end

--① 条件
function c12263004.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp)
end

--① 检索
function c12263004.thfilter(c)
	return c:IsSetCard(0x5244) and c:IsAbleToHand()
end
function c12263004.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c12263004.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c12263004.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c12263004.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--② 条件
function c12263004.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,0,TYPE_LINK+TYPE_RITUAL)
end

--② 装备
function c12263004.eqfilter(c)
	return c:IsSetCard(0x5244) and c:IsType(TYPE_MONSTER)
end
function c12263004.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(c12263004.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c12263004.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,c12263004.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	if ec and Duel.Equip(tp,ec,tc) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(function(e,c) return c==tc end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)

		if Duel.SelectYesNo(tp,aux.Stringid(12263004,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #rg>0 then
				Duel.SendtoHand(rg,nil,REASON_EFFECT)
			end
		end
	end
end

--③ 条件
function c12263004.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsType(TYPE_EQUIP)
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

--③ 筛选：自己场上 仪式怪兽 OR 链接怪兽 OR 天水卡（全场可破坏）
function c12263004.actfilter(c,e)
	return c:IsFaceup() and c:IsControler(e:GetHandlerPlayer())
		and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_LINK) or c:IsSetCard(0x5244))
		and c~=e:GetHandler() and c:IsCanBeEffectTarget(e)
end

--仪式怪兽：水·电子界族·仪式
function c12263004.ritfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsType(TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function c12263004.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c12263004.actfilter(chkc,e) end
	if chk==0 then
		return Duel.IsExistingTarget(c12263004.actfilter,tp,LOCATION_ONFIELD,0,1,nil,e)
			and Duel.IsExistingMatchingCard(c12263004.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c12263004.actfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function c12263004.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c12263004.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
--素材限制
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x5244,lc,sumtype,tp)
end
