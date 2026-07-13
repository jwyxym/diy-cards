--黏糊糊的天使
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2,s.matfilter3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.mtcon)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.matfilter1(c)
	return c:IsRace(RACE_FAIRY)
end
function s.matfilter2(c)
	return c:IsRace(RACE_AQUA)
end
function s.matfilter3(c)
	return c:IsRace(RACE_FAIRY) or c:IsRace(RACE_AQUA)
end
function s.valcheck(e,c)
	local tp=e:GetHandler():GetControler()
	local ct1=c:GetMaterial():FilterCount(Card.IsRace,nil,RACE_FAIRY)  
	local ct2=c:GetMaterial():FilterCount(Card.IsRace,nil,RACE_AQUA)	
	local ct3=c:GetMaterial():FilterCount(s.racefilter2,nil,tp)
	e:GetLabelObject():SetLabel(ct1,ct2,ct3)
end
function s.racefilter2(c,tp)
	return c:GetOwner()~=tp
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end

function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1,ct2,ct3=e:GetLabel()
	if ct1>0 then
		Duel.Draw(tp,ct1,REASON_EFFECT)
	end
	if ct2>0 then
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,2))
		e5:SetType(EFFECT_TYPE_QUICK_O)
		e5:SetCode(EVENT_FREE_CHAIN)
		e5:SetRange(LOCATION_MZONE)
		e5:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
		e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e5:SetCountLimit(1)
		e5:SetTarget(s.ovltg)
		e5:SetOperation(s.ovlop)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e5)
	end
	if ct2>1 then
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e4:SetCode(EVENT_CHAINING)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCountLimit(1)
		e4:SetCondition(s.discon2)
		e4:SetCost(s.discost)
		e4:SetOperation(s.disop2)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
	end
	if ct3>1 then
		local e6=Effect.CreateEffect(c)
		e6:SetDescription(aux.Stringid(id,0))
		e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_FUSION_SUMMON)
		e6:SetType(EFFECT_TYPE_QUICK_O)
		e6:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e6:SetCode(EVENT_FREE_CHAIN)
		e6:SetRange(LOCATION_MZONE)
		e6:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
		e6:SetCountLimit(1)
		e6:SetTarget(s.fustg)
		e6:SetOperation(s.fusop)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e6)
	end
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
end
function s.distg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsControler(1-tp)
end
function s.ovltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ovfilter(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1)
end
function s.ovlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
	local og=g:GetFirst()
	if not og then return end
	local mg=Group.FromCards(c,og)
	Duel.Overlay(tc,mg)
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tfilter10,1,nil,tp)
end
function s.tfilter10(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,nil,REASON_COST)
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end