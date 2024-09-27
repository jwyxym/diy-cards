--炽神界·天堂传火鸟
local cm,m,o=GetID()
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),4,2,nil,nil,5)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,m+3)
	e1:SetCondition(cm.con)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+4)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(cm.con1)
	e2:SetCost(cm.cost1)
	e2:SetTarget(cm.tg1)
	e2:SetOperation(cm.op1)
	c:RegisterEffect(e2)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cm.filter(c,e,tp)
	return c:IsSetCard(0x721) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.filter1(c)
	return c:IsSetCard(0x721) and c:IsCanOverlay()
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cm.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 
	and tc:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mg=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_HAND,0,1,1,nil)
		Duel.Overlay(tc,mg)
	end
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cm.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function cm.tg1f2(c,tc,e,tp,chk)
	if not (c:IsType(TYPE_XYZ) and c:IsSetCard(0x721) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0) then return false end
	if not (tc:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)) then return false end
	local r=c:GetRank()-tc:GetRank()
	if chk then return r==chk end
	return r>0 and e:GetHandler():CheckRemoveOverlayCard(tp,r,REASON_COST)
end
function cm.tg1f1(c,e,tp,chk)
	if not (c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(cm.tg1f2,tp,LOCATION_EXTRA,0,1,nil,c,e,tp,chk)) then return false end
	if chk then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) end
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FAIRY)
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cm.tg1f1(chkc,e,tp,e:GetLabel()) end
	if chk==0 then 
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingTarget(cm.tg1f1,tp,LOCATION_MZONE,0,1,nil,e,tp) 
	end
	e:SetLabel(0)
	local r_table, r_chk = {}, 0
	for tc in aux.Next(Duel.GetMatchingGroup(cm.tg1f1,tp,LOCATION_MZONE,0,nil,e,tp)) do
		for ec in aux.Next(Duel.GetMatchingGroup(cm.tg1f2,tp,LOCATION_EXTRA,0,nil,tc,e,tp)) do
			local r = ec:GetRank() - tc:GetRank()
			if r_chk&(1<<r) == 0 then
				r_chk = r_chk|(1<<r)
				table.insert(r_table,r)
			end
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88504133,1))
	r_chk=Duel.AnnounceNumber(tp,table.unpack(r_table))
	e:SetLabel(r_chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	e:GetHandler():RemoveOverlayCard(tp,r_chk,r_chk,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.tg1f1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,r_chk):GetFirst():RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,0,1,r_chk)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and tc:IsFaceup()
		and tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,cm.tg1f2,tp,LOCATION_EXTRA,0,1,1,nil,tc,e,tp,tc:GetFlagEffectLabel(m)):GetFirst()
		if sc then
			if #tc:GetOverlayGroup()>0 then
				Duel.Overlay(sc,tc:GetOverlayGroup())
			end
			sc:SetMaterial(Group.FromCards(tc))
			Duel.Overlay(sc,Group.FromCards(tc))
			if Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
				sc:RegisterFlagEffect(m,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_END)
				e2:SetCountLimit(1)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetLabelObject(sc)
				e2:SetValue(Duel.GetTurnCount())
				e2:SetCondition(cm.op1con2)
				e2:SetOperation(cm.op1op2)
				e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
				Duel.RegisterEffect(e2,tp)
			end
			Duel.SpecialSummonComplete()
			sc:CompleteProcedure()
		end
	end
end
function cm.op1con2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp or Duel.GetTurnCount()==e:GetValue() then return false end
	local res=e:GetLabelObject():GetFlagEffect(m)~=0
	if not res then e:Reset() end
	return res
end
cm.op1op2=function(e,tp,eg,ep,ev,re,r,rp) Duel.Destroy(e:GetLabelObject(),REASON_EFFECT) end
