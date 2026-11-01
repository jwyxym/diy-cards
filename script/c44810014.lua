--次元对决 侦探与魔盗
local s,id,o=GetID()
function s.initial_effect(c)
	--融合召唤
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	c:EnableReviveLimit()
	--特召限制    
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--放置    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.sdtg)
	e1:SetOperation(s.sdop)
	c:RegisterEffect(e1)
	--翻开   
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--无效    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(6)
end
function s.matfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PSYCHO) and c:IsLevelAbove(6)
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.sdfilter(c)
	return c:IsSetCard(0x3ce1,0x1d5c) 
end
function s.filter(c,g)
	return c:IsSetCard(0x3ce1) and g:IsExists(Card.IsSetCard,1,c,0x1d5c)
end
function s.gcheck(g)
	return g:IsExists(s.filter,1,nil,g)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.sdfilter,tp,LOCATION_DECK,0,nil)
	if g:CheckSubGroup(s.gcheck,2,2) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,6))
		local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
		if not sg then return end		
		for tc in aux.Next(sg) do
        	Duel.DisableShuffleCheck()
        	Duel.SendtoDeck(tc,1-tp,SEQ_DECKTOP,REASON_EFFECT)			
		end
		Duel.SortDecktop(tp,1-tp,sg:GetCount())
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thfilter(c)
	return c:IsSetCard(0x3ce1,0x1d5c) and c:IsAbleToHand()
end
function s.eqfilter(c,tp)
	return c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(1-tp,2)
	local g=Duel.GetDecktopGroup(1-tp,2)
	if g:GetCount()>0 then
    	Duel.DisableShuffleCheck()
    	if g:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
			if sg:GetCount()>0 then
				Duel.SendtoHand(sg,tp,REASON_EFFECT)
            	Duel.ConfirmCards(1-tp,sg)
                Duel.ShuffleHand(tp)
                g:Sub(sg)
            end
		end
        Duel.SortDecktop(tp,1-tp,g:GetCount())
		for i=1,g:GetCount() do
			local mg=Duel.GetDecktopGroup(1-tp,1)
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
        local c=e:GetHandler()
        local pg=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
        if pg:GetCount()>0 and pg:GetMinGroup(Card.GetSequence):FilterCount(s.eqfilter,nil,tp)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        	and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
            and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        	Duel.BreakEffect()
            local ec=pg:GetMinGroup(Card.GetSequence):Filter(s.eqfilter,nil,tp):GetFirst()
            if not Duel.Equip(tp,ec,c) then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(c)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(1300)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e2)
            ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
function s.costfilter(c,ec)
	return c:IsAbleToGraveAsCost() and c:GetSequence()<5 and c:GetFlagEffect(id)>0
    	and c:GetEquipTarget()==ec and c:IsFaceup()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
        if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        	Duel.BreakEffect()
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local rg=g:Select(tp,1,1,nil)
            Duel.HintSelection(rg)
            Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
        end
	end
end