--盘古斧
local this,id,ofs=GetID()
function this.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(this.con)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
	if not this.global_check then
		this.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(this.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function this.checkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(1-rp,id,RESET_PHASE+PHASE_END,0,1)
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFlagEffect(tp,id)
    if chk==0 then return
        Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
    end
    local cat=0
    if ct>=3 then
        cat=cat|CATEGORY_REMOVE
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
    end
    if ct>=1 then
        cat=cat|CATEGORY_DRAW
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
    if ct>=2 then
        cat=cat|CATEGORY_DISABLE
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
    e:SetCategory(cat|CATEGORY_DESTROY)
    if ct>=2 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(this.chainlm)
	end
end
function this.chainlm(e,rp,tp)
	return tp==rp
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local dc=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler()):GetFirst()
    if dc and Duel.Destroy(dc,REASON_EFFECT)>0 then
        local ct=Duel.GetFlagEffect(tp,id)
        if ct>=1 then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
        if ct>=2 then
            Duel.BreakEffect()
            Duel.NegateEffect(ev)
        end
        if ct>=3 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
            if tc then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
        end
    end
end
