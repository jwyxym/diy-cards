--Ode to Oblivion
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--发动条件：自己场上有符合条件的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
--怪兽检查：机械族·暗属性9阶超量怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsType(TYPE_XYZ) and c:IsRank(9) and c:GetOverlayCount()>=3
end
--cost：取除全部超量素材
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
		return g:GetCount()>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		e:SetLabel(tc:GetOverlayCount())
		--取除全部超量素材作为cost
		local ct=tc:GetOverlayCount()
		if ct>0 then
			tc:RemoveOverlayCard(tp,ct,ct,REASON_COST)
		end
		--将选择的怪兽设置为目标
		e:SetLabelObject(tc)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:IsLocation(LOCATION_MZONE) or ct==0 then return end
	
	--根据取除数量适用效果
	if ct>=3 then
		--效果1：这个回合，对方不能在战斗阶段发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.actlimit1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	
	if ct>=6 then
		--效果2：机械族·暗属性超量怪兽不受对方魔法陷阱影响，不能解放
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.immtg)
		e2:SetValue(s.immval)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e2,tp)
		
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_UNRELEASABLE_SUM)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(s.immtg)
		e3:SetValue(1)
		e3:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e3,tp)
		
		local e4=e3:Clone()
		e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		Duel.RegisterEffect(e4,tp)
	end
	
	if ct>=9 then
		--效果3：对方墓地·除外状态的卡全部作为那只怪兽的超量素材
		--收集对方墓地·除外状态的卡
		local g1=Duel.GetMatchingGroup(nil,tp,0,LOCATION_GRAVE,nil)
		local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_REMOVED,nil)
		if g1:GetCount()>0 or g2:GetCount()>0 then
			local mg=Group.CreateGroup()
			if g1:GetCount()>0 then
				mg:Merge(g1)
			end
			if g2:GetCount()>0 then
				mg:Merge(g2)
			end
			if mg:GetCount()>0 then
				Duel.Overlay(tc,mg)
			end
		end
	end
end
--效果1：战斗阶段不能发动效果
function s.actlimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
--效果2的目标：机械族·暗属性超量怪兽
function s.immtg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
end
--效果2的值：不受对方魔法陷阱效果影响
function s.immval(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
