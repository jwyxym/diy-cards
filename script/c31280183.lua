--淬铁龙匠 龙炎设计师
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2,s.lcheck)
	c:EnableReviveLimit()
	--送去墓地	
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--攻守上升
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)    
end
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
function s.tgfilter(c,e,tp,check)
	local b1=c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
    local b2=c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcca1) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
		and (c:IsAbleToGrave() or (check and (b1 or b2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,check) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local check=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,check):GetFirst()
	if tc then
    	local b1=tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
    	local b2=tc:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		if check and (b1 or b2) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            	local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(800)
				tc:RegisterEffect(e1)
            end
            Duel.SpecialSummonComplete()
		elseif tc:IsAbleToGrave() then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
function s.atkfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_PENDULUM) or c:IsSetCard(0xcca1))
end    
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local res=false
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)		
		e1:SetValue(400)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
    	local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
        res=true
    end
    if res and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and tc~=c
    	and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp)
        and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
		if not Duel.Equip(tp,c,tc) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)		
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end