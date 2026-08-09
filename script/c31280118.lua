--创造的丹紫·安涅儿
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280120)
	--融合召唤
	aux.AddFusionProcCodeFun(c,31280120,aux.FilterBoolFunction(Card.IsFusionSetCard,0x9caa),1,true,true)
	c:EnableReviveLimit()
	--种族视为机械族
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
    e0:SetCondition(s.racecon)
	e0:SetValue(RACE_MACHINE)
	c:RegisterEffect(e0)
	--复制效果    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCost(s.cpcost)
    e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)
	--特殊召唤    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)    
    local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon2)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	c:RegisterEffect(e3) 
end
function s.racecon(e)
    if e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	return true
end
function s.costfilter(c,res)
	local b1=res and c:IsLocation(LOCATION_DECK) and not c:IsCode(31280120) and c:IsType(TYPE_MONSTER)
    local b2=c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	return c:IsSetCard(0x9caa) and c:IsAbleToGraveAsCost() and (b1 or b2)
end
function s.excostfilter(c,tp)
	return c:IsFaceup() and c:IsHasEffect(31280120,tp)
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local fg=Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_MZONE,0,nil,tp)
	local res=fg:GetCount()>0 and c:IsSetCard(0x9caa)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,c,res) end    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,1,c,res)
    if g:GetFirst():IsLocation(LOCATION_DECK) then
    	Duel.Hint(HINT_CARD,0,31280120)
    	local sg=fg
        if fg:GetCount()>1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            sg=fg:Select(tp,1,1,nil)
        end
        Duel.HintSelection(sg)
        local tc=sg:GetFirst()
        local te=tc:IsHasEffect(31280120,tp)
        if te then
        	te:UseCountLimit(tp)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31280120,1))
        end
    end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.cpfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x9caa) and c:IsType(TYPE_MONSTER)) then return false end
	local te=c.machine_zombie_be_tograve_effect
	if not te then return false end
	local tg=te:GetTarget()
	return tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local cc=e:GetLabelObject()
		if cc and cc.machine_zombie_be_tograve_effect then
			local ce=cc.machine_zombie_be_tograve_effect
			local tg=ce:GetTarget()
			return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
        end    
	end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te=tc.machine_zombie_be_tograve_effect
	if te then
		local tg=te:GetTarget()
		if tg then
			local cchk=e:IsCostChecked()
			e:SetCostCheck(false)
			tg(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetCostCheck(cchk)
		end
	end
	Duel.ClearOperationInfo(0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToEffect(e) then
		local te=tc.machine_zombie_be_tograve_effect
		if te then
			local op=te:GetOperation()
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end
	end
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_MACHINE)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function s.spfilter(c,e,tp)
	local b1=c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x9caa)
    	and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or c:IsAbleToHand())
    local b2=c:IsLocation(LOCATION_EXTRA) and aux.IsCodeListed(c,31280120)
    	and ((Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or c:IsAbleToHand())        
	return c:IsType(TYPE_MONSTER) and not c:IsLevel(9) and (b1 or b2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
    	local con=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) 
        	and ((tc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
            	or (tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0))
		if tc:IsAbleToHand() and (not con or Duel.SelectOption(tp,1190,1152)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end