--辉夜大小姐想让我告白 伊井野弥子
local cm,m=GetID()

function cm.initial_effect(c)
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
    --
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,m)
    e2:SetCondition(cm.spcon)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(0x10)
    e1:SetCondition(cm.recon)
	e1:SetTarget(cm.retg)
	e1:SetOperation(cm.reop)
	c:RegisterEffect(e1)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_FIEND) or c:IsLinkAttribute(ATTRIBUTE_WATER)
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

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE)
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,0x04)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,0x50)
end

function cm.opsfilter(c,e,tp,tc)
    return c:IsLink(2) and not c:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,0x40,0,1,nil,Group.FromCards(c,tc),tc,2,2)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
        if Duel.IsExistingMatchingCard(cm.opsfilter,tp,0x04,0x04,1,c,e,tp,c) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
			local tc=Duel.SelectMatchingCard(tp,cm.opsfilter,tp,0x04,0x04,1,1,c,e,tp,c):GetFirst()
            if tc then
                local g=Group.FromCards(c,tc)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local rc=Duel.SelectMatchingCard(tp,Card.IsLinkSummonable,tp,0x40,0,1,1,nil,g,c,#g,#g):GetFirst()
                Duel.LinkSummon(tp,rc,g,c,#g,#g)
                local e5=Effect.CreateEffect(c)
                e5:SetType(EFFECT_TYPE_SINGLE)
                e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
                e5:SetCode(EFFECT_UNRELEASABLE_SUM)
                e5:SetRange(LOCATION_MZONE)
                e5:SetValue(1)
                rc:RegisterEffect(e5,true)
                local e6=e5:Clone()
                e6:SetDescription(aux.Stringid(m,1))
                e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
                e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
                rc:RegisterEffect(e6,true)
            end
        end
    end
end

function cm.recon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	return re:IsActiveType(0x1) and rc:IsType(TYPE_LINK) and rc:GetMaterial():IsContains(e:GetHandler())
end

function cm.tgrfilter(c)
    return c:IsLink(2) and c:IsAbleToDeck()
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(cm.tgrfilter,tp,0x10,0,1,c) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,2,tp,0x10)
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToChain() and c:IsAbleToDeck() then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,cm.tgrfilter,tp,0x10,0,1,1,c)
        if #g>0 then
            Duel.HintSelection(g)
            g:AddCard(c)
            Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
        end
    end
end