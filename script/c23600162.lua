--忘泉业 今昔果
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xd87),s.ffilter,true)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.recon1)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.reop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.recon2)
	e2:SetTarget(s.retg)
	e2:SetOperation(s.reop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SEARCH+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.fspcon)
	e4:SetTarget(s.fsptg)
	e4:SetOperation(s.fspop)
	c:RegisterEffect(e4)
end
function s.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsFusionSetCard(0xd87)
end
function s.recon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_SEASERPENT) and c:IsControler(tp)
end
function s.recon2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.ffilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_SEASERPENT)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(s.ffilter2,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,ct,0,0)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
function s.filter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(0xd87) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,e:GetHandler(),chkf)
	return res
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and e:GetHandler():IsReason(REASON_EFFECT)
end
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE,0,nil,e)
		local res=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter0),tp,LOCATION_GRAVE,0,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.fdfilter2,1,nil) then
				local cg=mat1:Filter(s.fdfilter2,nil)
				Duel.HintSelection(cg)
			end
			aux.PlaceCardsOnDeckBottom(tp,mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
function s.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end