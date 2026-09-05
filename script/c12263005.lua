--天水 ：源冈底斯
local s,id=GetID()
function s.initial_effect(c)
	--Link3 素材：包含天水怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),2,99,s.lcheck)
	c:EnableReviveLimit()

	--① 特殊召唤成功时
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12263005,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,12263005)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	--① 被破坏送去墓地时
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,12263005)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)

	--② 墓地 连接/仪式特召 装备天水+送墓
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12263005,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,122630051)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)

	--③ 装备状态 效果发动时 破坏+仪式召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12263005,2))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,122630052)
	e4:SetCondition(s.actcon)
	e4:SetTarget(s.acttg)
	e4:SetOperation(s.actop)
	c:RegisterEffect(e4)

	--装备限制
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end

--素材限制
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x5244,lc,sumtype,tp)
end

--① 破坏触发条件
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp)
end

--① 特殊召唤天水怪兽
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x5244) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>2 then ft=2 end

	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end

	local sg=g:Select(tp,1,ft,nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--② 条件：连接/仪式特召
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,0,TYPE_LINK+TYPE_RITUAL)
end

--② 装备用天水怪兽
function s.eqfilter(c)
	return c:IsSetCard(0x5244) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	if not ec then return end

	if not Duel.Equip(tp,ec,tc) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)

	--可选送墓1张
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=dg:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

--=============================================
-- 以下③效果 已完全替换为洪川正确版
--=============================================
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsType(TYPE_EQUIP)
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

--③ 筛选：自己场上 仪式怪兽 OR 链接怪兽 OR 天水卡（全场可破坏）
function s.actfilter(c,e)
	return c:IsFaceup() and c:IsControler(e:GetHandlerPlayer())
		and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_LINK) or c:IsSetCard(0x5244))
		and c~=e:GetHandler() and c:IsCanBeEffectTarget(e)
end

--仪式怪兽：水·电子界族·仪式
function s.ritfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsType(TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.actfilter(chkc,e) end
	if chk==0 then
		return Duel.IsExistingTarget(s.actfilter,tp,LOCATION_ONFIELD,0,1,nil,e)
			and Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.actfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
