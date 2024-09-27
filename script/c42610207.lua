--辉夜大小姐想让我告白 石上优
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
    --immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(cm.efilter)
	c:RegisterEffect(e1)
    --
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RELEASE+CATEGORY_RECOVER+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
	e2:SetTarget(cm.distg)
	e2:SetOperation(cm.disop)
	c:RegisterEffect(e2)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_FIEND) or c:IsLinkAttribute(ATTRIBUTE_EARTH)
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

function cm.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsRace(RACE_FIEND) and not te:GetHandler()==e:GetHandler()
end

function cm.tgdfilter(c)
    return c:IsReleasableByEffect() and c:GetBaseAttack()>0
end

function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsLink,nil,2)
	if chk==0 then return #g>0 and g:IsExists(cm.tgdfilter,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,nil,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,nil)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function cm.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
		local g=c:GetLinkedGroup():Filter(Card.IsLink,nil,2)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			g=g:FilterSelect(tp,cm.tgdfilter,1,1,nil)
			if #g>0 and Duel.Release(g,REASON_EFFECT) then
				local atk=g:GetFirst():GetBaseAttack()
				if atk>0 then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetRange(LOCATION_MZONE)
					e1:SetValue(atk)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					c:RegisterEffect(e1)
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
    end
end