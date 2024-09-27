--Re:从零开始的异世界生活 艾姬多娜
local cm,m=GetID()

function cm.initial_effect(c)
    aux.AddCodeList(c,10700512)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(cm.thcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_SPELLCASTER) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end

function cm.lcheck(g,lc)
	return g:IsExists(cm.lckfilter,1,nil)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0x04,0x04,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0x04,0x04,1,1,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(m,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_DARK)
		tc:RegisterEffect(e2)
    end
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(0x0c)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0x04,0,nil)>0 or c:IsAbleToDeck() end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,c,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end

function cm.optfilter(c)
    return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(cm.optfilter,tp,0x04,0,1,nil)
    local b2=c:IsRelateToChain() and c:IsAbleToDeck()
    if b1 or b2 then
        if b1 and (not b2 or Duel.SelectOption(tp,aux.Stringid(m,1),aux.Stringid(m,2))==0) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
            local g=Duel.SelectMatchingCard(tp,cm.optfilter,tp,0x04,0,1,1,nil)
            if #g>0 then
                Duel.HintSelection(g)
                local tc=g:GetFirst()
                if not tc:IsImmuneToEffect(e) then
                    local e2=Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
                    e2:SetValue(ATTRIBUTE_DARK)
                    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e2)
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_UPDATE_ATTACK)
                    e1:SetRange(LOCATION_MZONE)
                    e1:SetValue(500)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                end
            end
        else
            if Duel.Recover(tp,800,REASON_EFFECT) then
                Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
            end
        end
    end
end